!***************************************************************************
! basic_stats.f90
! ---------------
! Copyright (C) 2007-2011, Eco2s team, Gerardo Fratini
! Copyright (C) 2011-2019, LI-COR Biosciences, Inc.  All Rights Reserved.
! Author: Gerardo Fratini
!
! This file is part of EddyPro®.
!
! NON-COMMERCIAL RESEARCH PURPOSES ONLY - EDDYPRO® is licensed for 
! non-commercial academic and government research purposes only, 
! as provided in the EDDYPRO® End User License Agreement. 
! EDDYPRO® may only be used as provided in the End User License Agreement
! and may not be used or accessed for any commercial purposes.
! You may view a copy of the End User License Agreement in the file
! EULA_NON_COMMERCIAL.rtf.
!
! Commercial companies that are LI-COR flux system customers 
! are encouraged to contact LI-COR directly for our commercial 
! EDDYPRO® End User License Agreement.
!
! EDDYPRO® contains Open Source Components (as defined in the 
! End User License Agreement). The licenses and/or notices for the 
! Open Source Components can be found in the file LIBRARIES-ENGINE.txt.
!
! EddyPro® is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
!
!***************************************************************************
!
! \brief       Calculate basic statistics on working Set, at several processing level \n
!             (depending on the calling position).
! \author      Gerardo Fratini
! \note
! \sa
! \bug
! \deprecated
! \test
! \todo
!***************************************************************************
subroutine BasicStats(Set, nrow, ncol, nfold, printout)
    use m_common_global_var
    implicit none
    !> in/out variables
    integer, intent(in) :: nrow, ncol
    integer, intent(in) :: nfold
    logical, intent(in) :: printout
    real(kind = dbl), intent(in) :: Set(nrow, ncol)
    !> local variables
    integer :: i = 0
    integer :: j = 0
    integer :: Nact = 0
    integer :: cnt(3) = 0
    real(kind = dbl) :: Prime(nrow, ncol)
    real(kind = dbl) :: SumSquare(3)

    
    if (printout) then
        if (nfold == 1) then
            write(*, '(a)', advance = 'no') '  Calculating statistics..'
        else
            write(*, '(a,i1,a)', advance = 'no') '  Re-calculating statistics (',nfold,')..'
        end if
    end if

    !> raw covariances on original time series
    call CovarianceMatrixNoError(Set, size(Set, 1), size(Set, 2), Stats%Cov, error)

    if (nfold <= 6) then
        !> mean values (only before detrending, after is deleterious)
        call AverageNoError(Set, size(Set, 1), size(Set, 2), Stats%Mean, error)
        
        if (nfold == 6) then
            !> Quantile calculation is computationally expensive so does it only when needed
            call QuantileNoError(Set, size(Set, 1), size(Set, 2), Stats%Median, 0.5d0, error)
            call QuantileNoError(Set, size(Set, 1), size(Set, 2), Stats%Q1, 0.25d0, error)
            call QuantileNoError(Set, size(Set, 1), size(Set, 2), Stats%Q3, 0.75d0, error)
        end if

        !> fluctuations (only before detrending, after is deleterious)
        do j = u, pe
            if (E2Col(j)%present) then
                do i = 1, nrow
                    if (Set(i, j) /= error) then
                        Prime(i, j) = Set(i, j) - Stats%Mean(j)
                    else
                        Prime(i, j) = error
                    end if
                end do
            else
                Prime(:, j) = error
            end if
        end do
    else
        !> after detrending, Set contains fluctuations
        Prime = Set
    end if

    !> wind direction (only before rotation, after makes no sense)
    if (nfold <= 4) then
        call AverageWindDirection(Set, size(Set, 1), size(Set, 2), &
            E2Col(u)%instr%north_offset + magnetic_declination, Stats%wind_dir, error)
        call WindDirectionStDev(Set, size(Set, 1), size(Set, 2), Stats%wind_dir_stdev, error)
    end if

    !> Standard deviations
    do j = u, pe
        if (E2Col(j)%present) then
            Stats%StDev(j) = dsqrt(Stats%Cov(j, j))
        else
            Stats%StDev(j) = error
        end if
    end do

    !> skewness and kurtosis
    Stats%Skw = 0.d0
    Stats%Kur = 0.d0
    do j = u, pe
        if (E2Col(j)%present) then
            Nact = 0
            do i = 1, nrow
                if (Prime(i, j) /= error) then
                    Nact = Nact + 1
                    Stats%Skw(j) = Stats%Skw(j) + (Prime(i, j))**3
                    Stats%Kur(j) = Stats%Kur(j) + (Prime(i, j))**4
                end if
            end do
            if (Nact /= 0) then
                Stats%Skw(j) = Stats%Skw(j) / (Stats%StDev(j)**3) / dble(Nact - 1)
                Stats%Kur(j) = Stats%Kur(j) / (Stats%StDev(j)**4) / dble(Nact - 1)
            else
                Stats%Skw(j) = error
                Stats%Kur(j) = error
            end if
        else
            Stats%Skw(j) = error
            Stats%Kur(j) = error
        end if
    end do
    if (printout) write(*,'(a)') ' Done.'

    !> TKE (e.g. Stull, 1988)
    if (nfold == 7) then
        SumSquare = 0d0
        cnt = 0
        do j = u, w
            do i = 1, nrow
                if (Set(i, j) /= error) then
                    cnt(j) = cnt(j) + 1
                    SumSquare(j) = SumSquare(j) + Set(i, j)**2
                end if
            end do
        end do
        Stats%TKE = 0.5d0 * (SumSquare(u) / cnt(u) + SumSquare(v) / cnt(v) + SumSquare(w) / cnt(w))
    end if
end subroutine BasicStats
