!***************************************************************************
! rename_tmp_files_rp.f90
! -----------------------
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
! \brief       Remove "tmp" extension in temporary file names, specific to RP
! \author      Gerardo Fratini
! \note
! \sa
! \bug
! \deprecated
! \test
! \todo
!***************************************************************************
subroutine RenameTmpFilesRP()
    use m_rp_global_var
    implicit none
    !> local variables
    integer :: tmp_indx
    integer :: move_status = 1
    character(PathLen) :: OutPath

    write(*,'(a)', advance = 'no') ' Closing RP output files..'

    !> QC details file
    if (RPsetup%out_qc_details) then
        tmp_indx = index(QCdetails_Path, TmpExt)
        OutPath = QCdetails_Path(1: tmp_indx - 1)
        move_status = system(comm_move // '"' // QCdetails_Path(1:len_trim(QCdetails_Path)) // '" "' &
            // OutPath(1:len_trim(OutPath)) // '"' // comm_out_redirect // comm_err_redirect)
    end if

    !> Biomet measurements file
    if (EddyProProj%out_biomet) then
        tmp_indx = index(Biomet_Path, TmpExt)
        OutPath = Biomet_Path(1: tmp_indx - 1)
        move_status = system(comm_move // '"' // Biomet_Path(1:len_trim(Biomet_Path)) // '" "' &
            // OutPath(1:len_trim(OutPath)) // '"' // comm_out_redirect // comm_err_redirect)
    end if

    !> Stats1 file
    if (RPsetup%out_st(1)) then
        tmp_indx = index(St1_Path, TmpExt)
        OutPath = St1_Path(1: tmp_indx - 1)
        move_status = system(comm_move // '"' // St1_Path(1:len_trim(St1_Path)) // '" "' &
            // OutPath(1:len_trim(OutPath)) // '"' // comm_out_redirect // comm_err_redirect)
    end if

    !> Stats2 file
    if (RPsetup%out_st(2)) then
        tmp_indx = index(St2_Path, TmpExt)
        OutPath = St2_Path(1: tmp_indx - 1)
        move_status = system(comm_move // '"' // St2_Path(1:len_trim(St2_Path)) // '" "' &
            // OutPath(1:len_trim(OutPath)) // '"' // comm_out_redirect // comm_err_redirect)
    end if

    !> Stats3 file
    if (RPsetup%out_st(3)) then
        tmp_indx = index(St3_Path, TmpExt)
        OutPath = St3_Path(1: tmp_indx - 1)
        move_status = system(comm_move // '"' // St3_Path(1:len_trim(St3_Path)) // '" "' &
            // OutPath(1:len_trim(OutPath)) // '"' // comm_out_redirect // comm_err_redirect)
    end if

    !> Stats4 file
    if (RPsetup%out_st(4)) then
        tmp_indx = index(St4_Path, TmpExt)
        OutPath = St4_Path(1: tmp_indx - 1)
        move_status = system(comm_move // '"' // St4_Path(1:len_trim(St4_Path)) // '" "' &
            // OutPath(1:len_trim(OutPath)) // '"' // comm_out_redirect // comm_err_redirect)
    end if

    !> Stats5 file
    if (RPsetup%out_st(5)) then
        tmp_indx = index(St5_Path, TmpExt)
        OutPath = St5_Path(1: tmp_indx - 1)
        move_status = system(comm_move // '"' // St5_Path(1:len_trim(St5_Path)) // '" "' &
            // OutPath(1:len_trim(OutPath)) // '"' // comm_out_redirect // comm_err_redirect)
    end if

    !> Stats6 file
    if (RPsetup%out_st(6)) then
        tmp_indx = index(St6_Path, TmpExt)
        OutPath = St6_Path(1: tmp_indx - 1)
        move_status = system(comm_move // '"' // St6_Path(1:len_trim(St6_Path)) // '" "' &
            // OutPath(1:len_trim(OutPath)) // '"' // comm_out_redirect // comm_err_redirect)
    end if

    !> Stats7 file
    if (RPsetup%out_st(7)) then
        tmp_indx = index(St7_Path, TmpExt)
        OutPath = St7_Path(1: tmp_indx - 1)
        move_status = system(comm_move // '"' // St7_Path(1:len_trim(St7_Path)) // '" "' &
            // OutPath(1:len_trim(OutPath)) // '"' // comm_out_redirect // comm_err_redirect)
    end if


    if (NumUserVar > 0) then
        !> L1 to L7 user statistics
        if (RPsetup%out_st(1)) then
            tmp_indx = index(UserSt1_Path, TmpExt)
            OutPath = UserSt1_Path(1: tmp_indx - 1)
            move_status = system(comm_move // '"' // UserSt1_Path(1:len_trim(UserSt1_Path)) // '" "' &
                // OutPath(1:len_trim(OutPath)) // '"' // comm_out_redirect // comm_err_redirect)
        end if
        if (RPsetup%out_st(2)) then
            tmp_indx = index(UserSt2_Path, TmpExt)
            OutPath = UserSt2_Path(1: tmp_indx - 1)
            move_status = system(comm_move // '"' // UserSt2_Path(1:len_trim(UserSt2_Path)) // '" "' &
                // OutPath(1:len_trim(OutPath)) // '"' // comm_out_redirect // comm_err_redirect)
        end if
        if (RPsetup%out_st(3)) then
            tmp_indx = index(UserSt3_Path, TmpExt)
            OutPath = UserSt3_Path(1: tmp_indx - 1)
            move_status = system(comm_move // '"' // UserSt3_Path(1:len_trim(UserSt3_Path)) // '" "' &
                // OutPath(1:len_trim(OutPath)) // '"' // comm_out_redirect // comm_err_redirect)
        end if
        if (RPsetup%out_st(4)) then
            tmp_indx = index(UserSt4_Path, TmpExt)
            OutPath = UserSt4_Path(1: tmp_indx - 1)
            move_status = system(comm_move // '"' // UserSt4_Path(1:len_trim(UserSt4_Path)) // '" "' &
                // OutPath(1:len_trim(OutPath)) // '"' // comm_out_redirect // comm_err_redirect)
        end if
        if (RPsetup%out_st(5)) then
            tmp_indx = index(UserSt5_Path, TmpExt)
            OutPath = UserSt5_Path(1: tmp_indx - 1)
            move_status = system(comm_move // '"' // UserSt5_Path(1:len_trim(UserSt5_Path)) // '" "' &
                // OutPath(1:len_trim(OutPath)) // '"' // comm_out_redirect // comm_err_redirect)
        end if
        if (RPsetup%out_st(6)) then
            tmp_indx = index(UserSt6_Path, TmpExt)
            OutPath = UserSt6_Path(1: tmp_indx - 1)
            move_status = system(comm_move // '"' // UserSt6_Path(1:len_trim(UserSt6_Path)) // '" "' &
                // OutPath(1:len_trim(OutPath)) // '"' // comm_out_redirect // comm_err_redirect)
        end if
        if (RPsetup%out_st(7)) then
            tmp_indx = index(UserSt7_Path, TmpExt)
            OutPath = UserSt7_Path(1: tmp_indx - 1)
            move_status = system(comm_move // '"' // UserSt7_Path(1:len_trim(UserSt7_Path)) // '" "' &
                // OutPath(1:len_trim(OutPath)) // '"' // comm_out_redirect // comm_err_redirect)
        end if
    end if

    write(*,'(a)') ' Done.'
end subroutine RenameTmpFilesRP
