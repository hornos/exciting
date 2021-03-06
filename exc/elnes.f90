!
!
!
! Copyright (C) 2008 J. K. Dewhurst, S. Sharma and C. Ambrosch-Draxl.
! This file is distributed under the terms of the GNU General Public License.
! See the file COPYING for license details.
!
!
Subroutine elnes
      Use modmain
      Use modinput
      Implicit None
! local variables
      Integer :: ik, ist, jst
      Integer :: n, nsk (3), iw
      Real (8) :: wd, dw, w, t1
      Real (8) :: vecqc (3), qc
! allocatable arrays
      Real (8), Allocatable :: e (:, :, :)
      Real (8), Allocatable :: f (:, :, :)
      Real (8), Allocatable :: eps2 (:)
      Complex (8), Allocatable :: emat (:, :)
! initialise universal variables
      Call init0
      Call init1
! allocate local arrays
      Allocate (e(nstsv, nstsv, nkpt))
      Allocate (f(nstsv, nstsv, nkpt))
      Allocate (eps2(input%properties%dos%nwdos))
! allocate the matrix elements array for < i,k+G+q | exp(iq.r) | j,k >
      Allocate (emat(nstsv, nstsv))
! read in the density and potentials from file
      Call readstate
! read Fermi energy from file
      Call readfermi
! find the new linearisation energies
      Call linengy
! generate the APW radial functions
      Call genapwfr
! generate the local-orbital radial functions
      Call genlofr
! loop over k-points
      Do ik = 1, nkpt
! get the second-variational eigenvalues and occupancies from file
         Call getevalsv (vkl(:, ik), evalsv(:, ik))
         Call getoccsv (vkl(:, ik), occsv(:, ik))
! compute < i,k+G+q | exp(iq.r) | j,k > matrix elements
         Call genexpiqr (ik, emat)
         Do ist = 1, nstsv
            Do jst = 1, nstsv
               e (ist, jst, ik) = evalsv (jst, ik) - evalsv (ist, ik)
               t1 = dble (emat(ist, jst)) ** 2 + aimag (emat(ist, jst)) &
              & ** 2
               f (ist, jst, ik) = t1 * occsv (ist, ik) * &
              & (occmax-occsv(jst, ik))
            End Do
         End Do
      End Do
! number of subdivisions used for interpolation
      nsk (:) = Max &
     & (input%properties%dos%ngrdos/input%groundstate%ngridk(:), 1)
      n = nstsv * nstsv
! integrate over the Brillouin zone
      Call brzint (input%properties%dos%nsmdos, &
     & input%groundstate%ngridk, nsk, ikmap, &
     & input%properties%dos%nwdos, wdos, n, n, e, f, eps2)
! q-vector in Cartesian coordinates
      Call r3mv (bvec, input%properties%elnes%vecql, vecqc)
      qc = Sqrt (vecqc(1)**2+vecqc(2)**2+vecqc(3)**2)
      t1 = occmax / omega
      If (qc .Gt. input%structure%epslat) t1 = t1 / qc ** 2
      eps2 (:) = t1 * eps2 (:)
      Open (50, File='ELNES.OUT', Action='WRITE', Form='FORMATTED')
      wd = wdos (2) - wdos (1)
      dw = wd / dble (input%properties%dos%nwdos)
      Do iw = 1, input%properties%dos%nwdos
         w = dw * dble (iw-1) + wdos (1)
         Write (50, '(2G18.10)') w, eps2 (iw)
      End Do
      Close (50)
      Write (*,*)
      Write (*, '("Info(elnes):")')
      Write (*, '(" ELNES intensity distribution written to ELNES.OUT")&
     &')
      Write (*,*)
      Deallocate (e, f, eps2, emat)
      Return
End Subroutine
