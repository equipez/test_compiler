module evaluate_mod
!--------------------------------------------------------------------------------------------------!
! This is a module evaluating the objective/constraint function with Nan/Inf handling.
!
! Coded by Zaikun ZHANG (www.zhangzk.net).
!
! Started: August 2021
!
! Last Modified: Friday, December 17, 2021 PM04:54:04
!--------------------------------------------------------------------------------------------------!

use, non_intrinsic :: consts_mod, only : RP, IK
implicit none
private
public :: evalf
public :: evalfc
public :: eval_count, f_x0, constr_x0

! Remarks on EVAL_COUNT, F_X0, and CONSTR_X0:
! 1. Currently (20211217), EVAL_COUNT, F_X0, and CONSTR_X0 are only used in nonlinear constrained
! problems, where the user may provide the function/constraint value of the starting point X0.
! 2. EVAL_COUNT is only used to indicate whether the current evaluation is for the starting point.
! Even though it equals the number of function/constrained evaluation, it is not used to define NF.
! The solvers will count NF themselves.
integer(IK), save :: eval_count = 0_IK
real(RP), pointer, save :: f_x0 => null()
real(RP), pointer, save :: constr_x0(:) => null()


contains


subroutine evalf(calfun, x, f)

! Generic modules
use, non_intrinsic :: consts_mod, only : RP, HUGEFUN, DEBUGGING
use, non_intrinsic :: debug_mod, only : assert
use, non_intrinsic :: infnan_mod, only : is_nan, is_posinf
use, non_intrinsic :: pintrf_mod, only : FUN

implicit none

! Inputs
procedure(FUN) :: calfun
real(RP), intent(in) :: x(:)

! Output
real(RP), intent(out) :: f

! Local variables
character(len=*), parameter :: srname = 'EVALF'

! Preconditions
if (DEBUGGING) then
    ! X should not contain NaN if the initial X does not contain NaN and the subroutines generating
    ! trust-region/geometry steps work properly so that they never produce a step containing NaN/Inf.
    call assert(.not. any(is_nan(x)), 'X does not contain NaN', srname)
end if

!====================!
! Calculation starts !
!====================!

if (any(is_nan(x))) then
    ! Although this should not happen unless there is a bug, we include this case for security.
    f = sum(x)  ! Set F to NaN
else
    call calfun(x, f)  ! Evaluate F.

    ! Moderated extreme barrier: replace NaN/huge objective or constraint values with a large but
    ! finite value. This is naive. Better approaches surely exist.
    if (f > HUGEFUN .or. is_nan(f)) then
        f = HUGEFUN
    end if

    !! We may moderate huge negative values of F (NOT an extreme barrier), but we decide not to.
    !!f = max(-HUGEFUN, f)
end if


!====================!
!  Calculation ends  !
!====================!

! Postconditions
if (DEBUGGING) then
    ! With the moderated extreme barrier, F cannot be NaN/+Inf.
    call assert(.not. (is_nan(f) .or. is_posinf(f)), 'F is not NaN/+Inf', srname)
end if

end subroutine evalf


subroutine evalfc(calcfc, x, f, constr, cstrv)

! Generic modules
use, non_intrinsic :: consts_mod, only : RP, ZERO, HUGEFUN, HUGECON, DEBUGGING
use, non_intrinsic :: debug_mod, only : assert
use, non_intrinsic :: infnan_mod, only : is_nan, is_posinf, is_neginf
use, non_intrinsic :: pintrf_mod, only : FUNCON

implicit none

! Inputs
procedure(FUNCON) :: calcfc
real(RP), intent(in) :: x(:)

! Outputs
real(RP), intent(out) :: f
real(RP), intent(out) :: constr(:)
real(RP), intent(out) :: cstrv

! Local variables
character(len=*), parameter :: srname = 'EVALFC'

! Preconditions
if (DEBUGGING) then
    ! X should not contain NaN if the initial X does not contain NaN and the subroutines generating
    ! trust-region/geometry steps work properly so that they never produce a step containing NaN/Inf.
    call assert(.not. any(is_nan(x)), 'X does not contain NaN', srname)
end if

!====================!
! Calculation starts !
!====================!

if (any(is_nan(x))) then
    ! Although this should not happen unless there is a bug, we include this case for security.
    ! Set F, CONSTR, and CSTRV to NaN.
    f = sum(x)
    constr = f
    cstrv = f
else
    if (eval_count == 0 .and. associated(f_x0) .and. associated(constr_x0)) then
        f = f_x0
        nullify (f_x0)
        constr = constr_x0
        nullify (constr_x0)
    else
        call calcfc(x, f, constr)  ! Evaluate F and CONSTR.
    end if
    eval_count = eval_count + 1_IK

    ! Moderated extreme barrier: replace NaN/huge objective or constraint values with a large but
    ! finite value. This is naive, and better approaches surely exist.
    if (f > HUGEFUN .or. is_nan(f)) then
        f = HUGEFUN
    end if
    where (constr < -HUGECON .or. is_nan(constr))
        ! The constraint is CONSTR(X) >= 0, so NaN should be replaced with a large negative value.
        constr = -HUGECON  ! MATLAB code: constr(constr < -HUGECON | isnan(constr)) = -HUGECON
    end where

    ! Moderate huge positive values of CONSTR, or they may lead to Inf/NaN in subsequent calculations.
    ! This is NOT an extreme barrier.
    constr = min(HUGECON, constr)
    !! We may moderate F similarly, but we decide not to.
    !!f = max(-HUGEFUN, f)

    ! Evaluate the constraint violation for constraints CONSTR(X) >= 0.
    cstrv = maxval([-constr, ZERO])
end if

!====================!
!  Calculation ends  !
!====================!

! Postconditions
if (DEBUGGING) then
    ! With the moderated extreme barrier, F cannot be NaN/+Inf, CONSTR cannot be NaN/-Inf.
    call assert(.not. (is_nan(f) .or. is_posinf(f)), 'F is not NaN/+Inf', srname)
    call assert(.not. any(is_nan(constr) .or. is_neginf(constr)), &
        & 'CONSTR does not containt NaN/-Inf', srname)
    call assert(.not. (cstrv < ZERO .or. is_nan(cstrv) .or. is_posinf(cstrv)), &
        & 'CSTRV is nonnegative and not NaN/+Inf', srname)
end if

end subroutine evalfc


end module evaluate_mod
