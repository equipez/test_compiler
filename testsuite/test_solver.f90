module test_solver_mod
implicit none
private
public :: test_solver_unc
public :: test_solver_con


contains


subroutine test_solver_unc()

use, non_intrinsic :: consts_mod, only : RP, IK
use, non_intrinsic :: memory_mod, only : safealloc
use, non_intrinsic :: noise_mod, only : noisy, noisy_calfun, orig_calfun
use, non_intrinsic :: pintrf_mod, only : FUN
use, non_intrinsic :: prob_mod, only : PNLEN, problem_t, construct, destruct
use, non_intrinsic :: solver_unc_mod, only : solver_unc

implicit none

character(len=PNLEN) :: probname
integer(IK) :: ir
integer(IK) :: n
procedure(FUN), pointer :: calfun
real(RP) :: Delta0
real(RP) :: f
real(RP), allocatable :: x(:)
type(problem_t) :: prob


! Construct the testing problem.
probname = 'chebyqad'

do ir = 1, 3
    n = (ir - 1_IK) * 10_IK + 1_IK
    call construct(prob, probname, n)

    ! Read X0.
    call safealloc(x, prob % n) ! Not all compilers support automatic allocation yet, e.g., Absoft.
    x = noisy(prob % x0)

    ! Read objective/constraints.
    orig_calfun => prob % calfun
    calfun => noisy_calfun  ! Impose noise to the test problem

    ! Read other data.
    Delta0 = prob % Delta0

    ! Call the solver.
    !call solver_unc(calfun, x, f, Delta0)  ! sunf95 cannot handle this
    call solver_unc(noisy_calfun, x, f, Delta0)

    ! Try modifying PROB.
    prob % x0 = x

    print *, 'Unconstrained problem solved with X = ', prob % x0
    print *, ''

    ! Clean up.
    ! Destruct the testing problem.
    call destruct(prob)
    deallocate (x)
    nullify (calfun)
    nullify (orig_calfun)
end do

end subroutine test_solver_unc


subroutine test_solver_con()

use, non_intrinsic :: consts_mod, only : RP, IK
use, non_intrinsic :: memory_mod, only : safealloc
use, non_intrinsic :: noise_mod, only : noisy, noisy_calcfc, orig_calcfc
use, non_intrinsic :: pintrf_mod, only : FUNCON
use, non_intrinsic :: prob_mod, only : PNLEN, problem_t, construct, destruct
use, non_intrinsic :: solver_con_mod, only : solver_con

implicit none

character(len=PNLEN) :: probname
integer(IK) :: ir
integer(IK) :: m
procedure(FUNCON), pointer :: calcfc
real(RP) :: Delta0
real(RP) :: f
real(RP), allocatable :: Aineq(:, :)
real(RP), allocatable :: bineq(:)
real(RP), allocatable :: constr(:)
real(RP), allocatable :: x(:)
type(problem_t) :: prob


probname = 'hexagon'

do ir = 1, 3
    ! Construct the testing problem.
    call construct(prob, probname)

    ! Read X0.
    m = prob % m
    call safealloc(x, prob % n) ! Not all compilers support automatic allocation yet, e.g., Absoft.
    x = noisy(prob % x0)

    ! Read objective/constraints.
    orig_calcfc => prob % calcfc
    calcfc => noisy_calcfc  ! Impose noise to the test problem

    ! Read other data.
    call safealloc(Aineq, int(size(prob % Aineq, 1), IK), int(size(prob % Aineq, 2), IK))
    Aineq = prob % Aineq
    call safealloc(bineq, int(size(prob % bineq), IK))
    bineq = prob % bineq
    Delta0 = prob % Delta0

    ! Call the solver.
    !call solver_con(calcfc, x, f, constr, m, Aineq, bineq, Delta0)  ! sunf95 cannot handle this
    call solver_con(noisy_calcfc, x, f, constr, m, Aineq, bineq, Delta0)

    ! Try modifying PROB.
    prob % x0 = x

    print *, 'Constrained problem solved with X = ', prob % x0
    print *, ''

    ! Clean up.
    ! Destruct the testing problem.
    call destruct(prob)
    deallocate (x)
    deallocate (Aineq)
    deallocate (bineq)
    nullify (calcfc)
    nullify (orig_calcfc)
end do

end subroutine test_solver_con


end module test_solver_mod
