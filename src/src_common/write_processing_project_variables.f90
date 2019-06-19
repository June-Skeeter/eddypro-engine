!***************************************************************************
! write_processing_project_variables.f90
! --------------------------------------
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
! \brief       Read EddyPro configuration file, section [Project]
!              which is common to both RP and FCC
! \author      Gerardo Fratini
! \note
! \sa
! \bug
! \deprecated
! \test
! \todo
!***************************************************************************
subroutine WriteProcessingProjectVariables()
    use m_common_global_var
    implicit none
    !> local variables
    integer :: dot

    !> Initializations
    Auxfile%metadata   = 'none'
    Auxfile%biomet     = 'none'
    Dir%biomet         = 'none'
    Dir%main_out       = 'none'
    EddyProProj%fname_template = 'none'

    !> Project general info
    select case (EPPrjCTags(16)%value(1:1))
        case('1')
            EddyProProj%run_mode =  'express'
        case('2')
            EddyProProj%run_mode =  'md_retrieval'
        case default
            EddyProProj%run_mode =  'advanced'
    end select

    EddyProProj%title  = trim(adjustl(EPPrjCTags(4)%value))
    EddyProProj%id     = trim(adjustl(EPPrjCTags(5)%value))
    if (EddyProProj%id(1:1) /= '_') then
        EddyProProj%id = 'eddypro_' // trim(adjustl(EddyProProj%id))
    else
        EddyProProj%id = 'eddypro' // trim(adjustl(EddyProProj%id))
    end if

    !>  file type
    select case (EPPrjCTags(6)%value(1:1))
        case ('0')
        EddyProProj%ftype = 'licor_ghg'
        EddyProProj%fext = 'ghg'
        case ('1')
        EddyProProj%ftype = 'generic_ascii'
        case ('2')
        EddyProProj%ftype = 'tob1'
        case ('3')
        EddyProProj%ftype = 'eddymeas_bin'
        case ('4')
        EddyProProj%ftype = 'edisol_bin'
        case ('5')
        EddyProProj%ftype = 'generic_bin'
        case ('6')
        EddyProProj%ftype = 'alteddy_bin'
    end select

    !> If file type is different from GHG, metadata
    !> retrieval mode is not feasible so forces into advanced mode
    if (EddyProProj%ftype /= 'licor_ghg' &
        .and. EddyProProj%run_mode ==  'md_retrieval') &
        EddyProProj%run_mode =  'advanced'

    !> File names prototype and related
    if (EddyProProj%run_env /= 'embedded') then
        EddyProProj%fname_template = &
            trim(adjustl(EPPrjCTags(7)%value))
        if (index(EddyProProj%fname_template, '.') /= 0) then
            !> File extensions
            dot = index(EddyProProj%fname_template, '.', .true.)
            EddyProProj%fext = &
            EddyProProj%fname_template(dot + 1:len_trim(EddyProProj%fname_template))
            !> ISO format
            EddyProLog%iso_format = index(EddyProProj%fname_template, 'mm') /= 0
        end if
    else
        EddyProLog%iso_format = .true.
        EddyProProj%fname_template = 'yyyy-mm-ddTHHMM'
    end if

    !> If file type is TOB1, check if user entered the format
    FileInterpreter%tob1_format = 'none'
    if (EddyProProj%ftype == 'tob1') then
        select case (trim(adjustl(EPPrjCTags(32)%value)))
            case ('1')
                FileInterpreter%tob1_format = 'IEEE4'
            case ('2')
                FileInterpreter%tob1_format = 'FP2'
        end select
    end if

    !> Whether to use alternative metadata file
    EddyProProj%use_extmd_file = EPPrjCTags(9)%value(1:1) == '1'
    AuxFile%metadata ='none'
    if(EddyProProj%use_extmd_file) &
        AuxFile%metadata = trim(adjustl(EPPrjCTags(10)%value))

    !> Whether to use dynamic metadata file
    EddyProProj%use_dynmd_file = EPPrjCTags(11)%value(1:1) == '1'
    if(EddyProProj%use_dynmd_file) &
        AuxFile%DynMD = trim(adjustl(EPPrjCTags(12)%value))

    !> Settings for binary raw files
    if (EddyProProj%ftype(1:len_trim(EddyProProj%ftype)) == 'generic_bin') then
        !> select line terminator in ASCII header of binary files
        select case(EPPrjCTags(13)%value(1:1))
            case ('0')
            Binary%ascii_head_eol = 'cr/lf'
            case ('1')
            Binary%ascii_head_eol = 'lf'
            case ('2')
            Binary%ascii_head_eol = 'cr'
        end select
        !> select binary files endianess
        Binary%little_endian = EPPrjCTags(14)%value(1:1) == '1'
        !> Select number of bytes per variable
        Binary%nbytes = nint(EPPrjNTags(1)%value)
        !> Select number of ASCII header lines
        Binary%head_nlines = nint(EPPrjNTags(2)%value)
    end if

    !> Master sonic
    EddyProProj%master_sonic = trim(adjustl(EPPrjCTags(15)%value))
    !> Variables to be used other than sonic ones
    EddyProProj%col(ts:pe) = nint(error)
    EddyProProj%col(ts)  = nint(EPPrjNTags(3)%value)
    EddyProProj%col(co2) = nint(EPPrjNTags(4)%value)
    EddyProProj%col(h2o) = nint(EPPrjNTags(5)%value)
    EddyProProj%col(ch4) = nint(EPPrjNTags(6)%value)
    EddyProProj%col(gas4) = nint(EPPrjNTags(7)%value)
    EddyProProj%col(tc)  = nint(EPPrjNTags(8)%value)
    EddyProProj%col(ti1) = nint(EPPrjNTags(9)%value)
    EddyProProj%col(ti2) = nint(EPPrjNTags(10)%value)
    EddyProProj%col(pi)  = nint(EPPrjNTags(11)%value)
    EddyProProj%col(te)  = nint(EPPrjNTags(12)%value)
    EddyProProj%col(pe)  = nint(EPPrjNTags(13)%value)
    EddyProProj%col(E2NumVar + diag72) = nint(EPPrjNTags(14)%value)
    EddyProProj%col(E2NumVar + diag75) = nint(EPPrjNTags(15)%value)
    EddyProProj%col(E2NumVar + diag77) = nint(EPPrjNTags(16)%value)
    EddyProProj%col(E2NumVar + diagAnem) = nint(EPPrjNTags(20)%value)
    EddyProProj%col(E2NumVar + diagStaA) = nint(EPPrjNTags(21)%value)
    EddyProProj%col(E2NumVar + diagStaD) = nint(EPPrjNTags(22)%value)

    !> if a column was selected for gas4, read diffusivity. If diffusivity is
    !> below zero, defaults to gas4 diffusivity
    if (EddyProProj%col(gas4) > 0) then
        Dc(gas4) = EPPrjNTags(17)%value * 1d-4 !< takes from cm+2s-1 to m+2s-1
        if (Dc(gas4) <= 0) Dc(gas4) = 0.00001436d0  !< default for N2O from Massman (1998, J. Atm. Env) Table 2.
        MW(gas4) = sngl(EPPrjNTags(18)%value) * 1e-3 !< takes from g+1mol-1 to kg+1mol-1
        if (MW(gas4) <= 0) MW(gas4) = 44.01e-3  !< default for N2O
    end if

    !> biomet measurements info
    select case (EPPrjCTags(17)%value(1:1))
        case ('1')
        EddyProProj%biomet_data = 'embedded'
        case ('2')
        EddyProProj%biomet_data = 'ext_file'
        case ('3')
        EddyProProj%biomet_data = 'ext_dir'
        case default
        EddyProProj%biomet_data = 'none'
    end select
    !> biomet files/folders as applicable
    if (EddyProProj%biomet_data == 'ext_file') &
        AuxFile%biomet = trim(adjustl(EPPrjCTags(18)%value))
    if (EddyProProj%biomet_data == 'ext_dir') then
        Dir%biomet = trim(adjustl(EPPrjCTags(29)%value))
        if (len_trim(Dir%biomet) == 0) then
            Dir%biomet = 'none'
        else
            EddyProProj%biomet_tail = trim(adjustl(EPPrjCTags(30)%value))
            EddyProProj%biomet_recurse = EPPrjCTags(31)%value(1:1) == '1'
        end if
    end if

    !> If selected embedded biomet without GHG files (only possible via non-GUI
    !> file edit), set biomet to none.
    if (EddyProProj%biomet_data == 'embedded' &
        .and. EddyProProj%ftype /= 'licor_ghg') then
        call ExceptionHandler(93)
        EddyProProj%biomet_data = 'none'
    end if

    !> select whether to binned/full spectra files are available
    !> for current dataset
    EddyProProj%binned_spec_avail = EPPrjCTags(44)%value(1:1) == '1'
    EddyProProj%full_spec_avail   = EPPrjCTags(45)%value(1:1) == '1'

    !> select whether to output full output file
    EddyProProj%out_full = EPPrjCTags(21)%value(1:1) == '1'
    !> select whether to use fixed or dynamic output format
    EddyProProj%out_md = EPPrjCTags(39)%value(1:1) == '1'
    !> select whether to output average cospectra
    EddyProProj%out_avrg_cosp = EPPrjCTags(41)%value(1:1) == '1'
    !> select whether to output average spectra
    EddyProProj%out_avrg_spec = EPPrjCTags(43)%value(1:1) == '1'
    !> select whether to output biomet average values
    EddyProProj%out_biomet = EPPrjCTags(42)%value(1:1) == '1'
    !> select whether to use fixed or dynamic output format
    EddyProProj%fix_out_format = EPPrjCTags(37)%value(1:1) == '1'

    !> Select whether to apply high-pass theoretical spectral correction.
    !> It is independent from the choice of the low-pass method
    select case (EPPrjCTags(22)%value(1:1))
        case ('0')
            !> Do not apply low-frequency spectral correction
            EddyProProj%lf_meth = 'none'
        case ('1')
            EddyProProj%lf_meth = 'analytic'
    end select

    !> Select low-pass spectral correction method.
    select case (EPPrjCTags(23)%value(1:1))
        case ('0')
            !> Do not apply spectral correction (e.g. open-path)
            EddyProProj%hf_meth = 'none'
            EddyProProj%hf_meth_in_situ = .false.
        case ('1')
            !> Correction after Moncrieff et al (1997, JH) fully analytical
            EddyProProj%hf_meth = 'moncrieff_97'
            EddyProProj%hf_meth_in_situ = .false.
        case ('2')
            !> Correction after Horst (1997, BLM), in-situ/analytical
            EddyProProj%hf_meth = 'horst_97'
            EddyProProj%hf_meth_in_situ = .true.
        case ('3')
            !> Correction after Ibrom et al (2007, AFM) fully in-situ
            EddyProProj%hf_meth = 'ibrom_07'
            EddyProProj%hf_meth_in_situ = .true.
        case ('4')
            !> Correction after Fratini et al. 2010, fully in-situ
            EddyProProj%hf_meth = 'fratini_12'
            EddyProProj%hf_meth_in_situ = .true.
        case ('5')
            !> Correction after Massman (2000, 2001), fully analytical
            EddyProProj%hf_meth = 'massman_00'
            EddyProProj%hf_meth_in_situ = .false.
        case ('6')
            !> Custom correction, in-situ/analytical
            EddyProProj%hf_meth = 'custom'
            EddyProProj%hf_meth_in_situ = .false.
        case default
            !> If not specified, set to none
            EddyProProj%hf_meth = 'none'
            EddyProProj%hf_meth_in_situ = .false.
    end select

    !> select whether to correct for LI-7550-related attenuations
    !> Relevant only for GHG files and logger software version < 7.7.0
    ! !>  Block-averaging
    ! EddyProProj%hf_correct_ghg_ba = EPPrjCTags(46)%value(1:1) == '1'
    ! !>  ZOH
    ! EddyProProj%hf_correct_ghg_zoh = EPPrjCTags(47)%value(1:1) == '1'
    ! if (EddyProProj%ftype /= 'licor_ghg') then
    !     EddyProProj%hf_correct_ghg_ba = .false.
    !     EddyProProj%hf_correct_ghg_zoh = .false.
    ! end if
    EddyProProj%hf_correct_ghg_ba = .false.
    EddyProProj%hf_correct_ghg_zoh = .false.

    EddyProProj%sonic_output_rate = nint(EPPrjNTags(19)%value)

    !> select whether to fill gaps with error codes
    EddyProProj%make_dataset = EPPrjCTags(24)%value(1:1) == '1'

    !> start/end date and time of period to be processed
    EddyProProj%subperiod = EPPrjCTags(40)%value(1:1) == '1'

    if (EddyProProj%subperiod) then
        EddYProProj%start_date = &
            trim(adjustl(EPPrjCTags(25)%value))
        EddYProProj%start_time = &
            trim(adjustl(EPPrjCTags(26)%value))
        EddYProProj%end_date = &
            trim(adjustl(EPPrjCTags(27)%value))
        EddYProProj%end_time = &
            trim(adjustl(EPPrjCTags(28)%value))
    end if

    if (len_trim(EddYProProj%start_date) == 0 &
        .or. len_trim(EddYProProj%start_time) == 0 &
        .or. len_trim(EddYProProj%end_date) == 0 &
        .or. len_trim(EddYProProj%end_time) == 0) &
        EddyProProj%subperiod = .false.

    !> select whether to apply WPL correction
    EddyProProj%wpl = EPPrjCTags(33)%value(1:1) /= '0'

    !> set error string
    EddyProProj%err_label = trim(adjustl(EPPrjCTags(36)%value))
    if (len_trim(EddyProProj%err_label) == 0 .or. EddyProProj%err_label == 'none') &
        EddyProProj%err_label = '-9999'

    !> select footprint method
    select case (EPPrjCTags(34)%value(1:1))
        case ('0')
        Meth%foot = 'none'
        case ('1')
        Meth%foot = 'kljun_04'
        case ('2')
        Meth%foot = 'kormann_meixner_01'
        case ('3')
        Meth%foot = 'hsieh_00'
        case default
        Meth%foot = 'kljun_04'
    end select

    !> select quality-flagging method
    select case (EPPrjCTags(38)%value(1:1))
        case ('0')
        Meth%qcflag = 'none'
        case ('1')
        Meth%qcflag = 'mauder_foken_04'
        case ('2')
        Meth%qcflag = 'foken_03'
        case ('3')
        Meth%qcflag = 'goeckede_06'
        case default
        Meth%qcflag = 'mauder_foken_04'
    end select

    !> Select whether to standardize biomets or not
    EddyProProj%fluxnet_standardize_biomet = EPPrjCTags(48)%value(1:1) == '1'
    EddyProProj%fluxnet_mode = EPPrjCTags(49)%value(1:1) == '1'

    !> main output directory, only in Desktop mode
    if (EddyProProj%run_env /= 'embedded') then
        Dir%main_out = EPPrjCTags(35)%value
        if (len_trim(Dir%main_out) == 0) then
            write(*, *)
            call ExceptionHandler(36)
        end if
        call AdjDir(Dir%main_out, slash)
    end if

    !> Random error estimation settings
    select case (nint(EPPrjNTags(24)%value))
        case(1)
            RUsetup%meth = 'finkelstein_sims_01'
        case(2)
            RUsetup%meth = 'mann_lenschow_94'
        case(3)
            RUsetup%meth = 'mahrt_98'
        case default
            RUsetup%meth = 'none'
    end select
    if (RUsetup%meth /= 'none') then
        select case (nint(EPPrjNTags(23)%value))
            case(1)
                RUsetup%its_meth = 'cross_0'
            case(2)
                RUsetup%its_meth = 'full_integral'
            case default
                RUsetup%its_meth = 'cross_e'
        end select
        RUsetup%tlag_max = nint(EPPrjNTags(25)%value)
    end if

    !> Adjust paths
    call AdjFilePath(AuxFile%metadata, slash)
    call AdjFilePath(AuxFile%biomet, slash)
    call AdjDir(Dir%biomet, slash)
end subroutine WriteProcessingProjectVariables
