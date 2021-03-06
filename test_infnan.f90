!        This is file : test_infnan
! Author= zaikunzhang
! Started at: 29.04.2022
! Last Modified: Sunday, May 22, 2022 PM05:31:55

program test_infnan

!use, intrinsic :: iso_fortran_env, only : RP => REAL32  ! Should be tested also
!use, intrinsic :: iso_fortran_env, only : RP => REAL64  ! Should be tested also
use, intrinsic :: iso_fortran_env, only : RP => REAL128
use, intrinsic :: ieee_arithmetic, only : ieee_is_nan
implicit none
real(RP) :: l, u, d, x, y, z

l = -huge(0.0_RP) / 4.0_RP
u = huge(0.0_RP) / 4.0_RP
d = 1.0E-002_RP
y = l / d
z = u / d
x = y - y

write (*, *) 'X = ', x, 'Expected NaN'
write (*, *) 'Y = ', y, 'Expected -Inf'
write (*, *) 'ABS(Y) = ', abs(y), 'Expected Inf'
write (*, *) 'Z = ', z, 'Expected Inf'
write (*, *) 'ABS(Z) = ', abs(z), 'Expected Inf'
write (*, *) 'Y < 0?', y < 0
write (*, *) 'Z < 0?', z < 0
write (*, *) 'Y is NaN?', ieee_is_nan(y)
write (*, *) 'Z is NaN?', ieee_is_nan(z)
write (*, *) 'Y < X?', y < x
write (*, *) 'Z > X?', z > x

if (ieee_is_nan(y) .and. (y < 0 .or. y > 0 .or. y == 0)) then
    write (*, *) 'Error: Y is both NaN and not NaN'
    stop 1
end if

if (ieee_is_nan(z) .and. (z < 0 .or. z > 0 .or. z == 0)) then
    write (*, *) 'Error: Z is both NaN and not NaN'
    stop 2
end if

if (ieee_is_nan(x) .and. y < x) then
    write (*, *) 'Error: -Inf < NaN'
    stop 3
end if

if (ieee_is_nan(x) .and. z > x) then
    write (*, *) 'Error: Inf > NaN'
    stop 4
end if

end program test_infnan
