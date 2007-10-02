
! Copyright (C) 2007 J. K. Dewhurst, S. Sharma and C. Ambrosch-Draxl.
! This file is distributed under the terms of the GNU General Public License.
! See the file COPYING for license details.

subroutine writevsim
use modmain
implicit none
! local variables
integer is,ia
real(8) v1(3),v2(3),v3(3),v4(3),t1
real(8) dxx,dyx,dyy,dzx,dzy,dzz
! external functions
real(8) r3dot
external r3dot
! determine coordinate system vectors
t1=sqrt(avec(1,1)**2+avec(2,1)**2+avec(3,1)**2)
v1(:)=avec(:,1)/t1
t1=sqrt(avec(1,2)**2+avec(2,2)**2+avec(3,2)**2)
v2(:)=avec(:,2)/t1
call r3cross(v1,v2,v3)
t1=sqrt(v3(1)**2+v3(2)**2+v3(3)**2)
v3(:)=v3(:)/t1
call r3cross(v3,v1,v2)
t1=sqrt(v2(1)**2+v2(2)**2+v2(3)**2)
v2(:)=v2(:)/t1
dxx=r3dot(avec(1,1),v1)
dyx=r3dot(avec(1,2),v1)
dyy=r3dot(avec(1,2),v2)
dzx=r3dot(avec(1,3),v1)
dzy=r3dot(avec(1,3),v2)
dzz=r3dot(avec(1,3),v3)
open(50,file='crystal.ascii',action='WRITE',form='FORMATTED')
write(50,*)
write(50,'(3G18.10)') dxx,dyx,dyy
write(50,'(3G18.10)') dzx,dzy,dzz
write(50,*)
do is=1,nspecies
  do ia=1,natoms(is)
    v4(1)=r3dot(atposc(1,ia,is),v1)
    v4(2)=r3dot(atposc(1,ia,is),v2)
    v4(3)=r3dot(atposc(1,ia,is),v3)
    write(50,'(3G18.10," ",A)') v4,trim(spsymb(is))
  end do
end do
close(50)
write(*,*)
write(*,'("Info(writevsim):")')
write(*,'(" V_Sim file written to crystal.ascii")')
return
end subroutine
