!--------------------------------------------------------------------------------------------------!
! This is an example to illustrate the usage of COB.
!
! Coded by Zaikun ZHANG (www.zhangzk.net) based on Powell's Fortran 77 code.
!
! Started: July 2020
!
! Last Modified: Tuesday, February 22, 2022 PM08:32:13
!--------------------------------------------------------------------------------------------------!

module test_cob_mod
implicit none
private
public :: test_cob

contains

subroutine test_cob()

! The following line makes COB available.
!--------------------------------------------------------------------------------------------------!
use cob_mod, only : cob
!--------------------------------------------------------------------------------------------------!

implicit none

integer :: i, n, alloc_stat
real(kind(0.0D0)) :: f
real(kind(0.0D0)), allocatable :: x(:)

! If CALCFC is an external subroutine, then remove the line of  "use calcfc_mod, only : calcfc", and
! uncomment the following line.
!--------------------------------------------------------------------------------------------------!
!external calcfc
!--------------------------------------------------------------------------------------------------!

do n = 2, 10, 2
    ! Set up the initial X for the Chebyquad problem.
    if (allocated(x)) deallocate (x)
    allocate (x(n), stat=alloc_stat)
    if (alloc_stat /= 0) print *, 'Memory allocation failed.'
    do i = 1, n
        x(i) = real(i, kind(0.0D0)) / real(n + 1, kind(0.0D0))
    end do

    print '(/1A, I2)', 'Result with N = ', n

    ! The following line illustrates how to call COB.
    !----------------------------------------------------------------------------------------------!
    call cob(calcfc, x, f, rhobeg=0.2D0 * x(1), iprint=2)
    !----------------------------------------------------------------------------------------------!
    ! In additon to the required arguments CALCFC, X, and F, the above illustration specifies also
    ! RHOBEG and IPRINT, which are optional. All the unspecified optional arguments (RHOEND, MAXFUN,
    ! etc.) will take their default values coded in COB. You can also ignore all the optional
    ! arguments and invoke COB by the following line.
    !----------------------------------------------------------------------------------------------!
    ! call cob(calcfc, x, f)
    !----------------------------------------------------------------------------------------------!
end do
end subroutine test_cob


subroutine calcfc(x, f, constr)
! The Chebyquad test problem (Fletcher, 1965)
implicit none

real(kind(0.0D0)), intent(in) :: x(:)
real(kind(0.0D0)), intent(out) :: f
real(kind(0.0D0)), intent(out) :: constr(:)

integer :: i, n
real(kind(0.0D0)) :: y(size(x) + 1, size(x) + 1), tmp

n = size(x)

y(1:n, 1) = 1.0D0
y(1:n, 2) = 2.0D0 * x - 1.0D0
do i = 2, n
    y(1:n, i + 1) = 2.0D0 * y(1:n, 2) * y(1:n, i) - y(1:n, i - 1)
end do

f = 0.0D0
do i = 1, n + 1
    tmp = sum(y(1:n, i)) / real(n, kind(0.0D0))
    if (mod(i, 2) /= 0) then
        tmp = tmp + 1.0D0 / real(i * i - 2 * i, kind(0.0D0))
    end if
    f = f + tmp * tmp
end do
constr = 0.0D0
end subroutine calcfc

end module test_cob_mod
