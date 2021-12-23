subroutine construct_chrosen(prob, n)
use, non_intrinsic :: consts_mod, only : IK, ONE, HALF, HUGENUM
use, non_intrinsic :: memory_mod, only : safealloc
implicit none

! Inputs
integer(IK), intent(in) :: n

! Outputs
type(problem_t), intent(out) :: prob

prob % probname = 'chrosen'
prob % probtype = 'u'
prob % m = 0
prob % n = n
call safealloc(prob % x0, n)  ! Not needed if F2003 is fully supported. Needed by Absoft 22.0.
prob % x0 = -ONE
call safealloc(prob % lb, n)
prob % lb = -HUGENUM
call safealloc(prob % ub, n)
prob % ub = HUGENUM
call safealloc(prob % Aeq, 0_IK, n)
call safealloc(prob % beq, 0_IK)
call safealloc(prob % Aineq, 0_IK, n)
call safealloc(prob % bineq, 0_IK)
prob % Delta0 = HALF
prob % calfun => calfun_chrosen
prob % calcfc => calcfc_chrosen
end subroutine construct_chrosen


subroutine calfun_chrosen(x, f)
! Chained Rosenbrock function.
use, non_intrinsic :: consts_mod, only : RP, IK, ONE
implicit none

real(RP), intent(in) :: x(:)
real(RP), intent(out) :: f

integer(IK) :: n
real(RP), parameter :: alpha = 1.0E2_RP

n = int(size(x), kind(n))
f = sum((x(1:n - 1) - ONE)**2 + alpha * (x(2:n) - x(1:n - 1)**2)**2); 
end subroutine calfun_chrosen


subroutine calcfc_chrosen(x, f, constr)
use, non_intrinsic :: consts_mod, only : RP, ZERO
implicit none
real(RP), intent(in) :: x(:)
real(RP), intent(out) :: f
real(RP), intent(out) :: constr(:)
call calfun_chrosen(x, f)
constr = ZERO
end subroutine calcfc_chrosen
