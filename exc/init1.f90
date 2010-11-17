!
!
!
! Copyright (C) 2002-2005 J. K. Dewhurst, S. Sharma and C. Ambrosch-Draxl.
! This file is distributed under the terms of the GNU General Public License.
! See the file COPYING for license details.
!
!BOP
! !ROUTINE: init1
! !INTERFACE:
!
!
Subroutine init1
! !USES:
      Use modinput
      Use modmain
#ifdef TETRA
      Use modtetra
#endif
#ifdef XS
      Use modxs
#endif
! !DESCRIPTION:
!   Generates the $k$-point set and then allocates and initialises global
!   variables which depend on the $k$-point set.
!
! !REVISION HISTORY:
!   Created January 2004 (JKD)
!EOP
!BOC
      Implicit None
! local variables
      Integer :: ik, is, ia, ias, io, ilo
      Integer :: i1, i2, i3, ispn, iv (3)
      Integer :: l1, l2, l3, m1, m2, m3, lm1, lm2, lm3
      Integer :: n1, n2, n3
      Real (8) :: vl (3), vc (3), boxl (3, 4), lambda
      Real (8) :: ts0, ts1
      Real (8) :: blen(3), lambdab
! external functions
      Complex (8) gauntyry
      External gauntyry
!
      Call timesec (ts0)
!
!---------------------!
!     k-point set     !
!---------------------!
! check if the system is an isolated molecule
      If (input%structure%molecule) Then
         input%groundstate%ngridk (:) = 1
         input%groundstate%vkloff (:) = 0.d0
         input%groundstate%autokpt = .False.
      End If
! setup the default k-point box
      boxl (:, 1) = input%groundstate%vkloff(:) / dble &
     & (input%groundstate%ngridk(:))
      boxl (:, 2) = boxl (:, 1)
      boxl (:, 3) = boxl (:, 1)
      boxl (:, 4) = boxl (:, 1)
      boxl (1, 2) = boxl (1, 2) + 1.d0
      boxl (2, 3) = boxl (2, 3) + 1.d0
      boxl (3, 4) = boxl (3, 4) + 1.d0
! k-point set and box for Fermi surface plots
      If ((task .Eq. 100) .Or. (task .Eq. 101)) Then
         input%groundstate%ngridk (:) = np3d (:)
         boxl (:, :) = vclp3d (:, :)
      End If
      If ((task .Eq. 20) .Or. (task .Eq. 21)) Then
! for band structure plots generate k-points along a line
         nvp1d = size &
        & (input%properties%bandstructure%plot1d%path%pointarray)
         npp1d = input%properties%bandstructure%plot1d%path%steps
         If (allocated(dvp1d)) deallocate (dvp1d)
         Allocate (dvp1d(nvp1d))
         If (allocated(vplp1d)) deallocate (vplp1d)
         Allocate (vplp1d(3, npp1d))
         If (allocated(dpp1d)) deallocate (dpp1d)
         Allocate (dpp1d(npp1d))
         Call connect (bvec, input%properties%bandstructure%plot1d, &
        & nvp1d, npp1d, vplp1d, dvp1d, dpp1d)
!
         nkpt = input%properties%bandstructure%plot1d%path%steps
         If (allocated(vkl)) deallocate (vkl)
         Allocate (vkl(3, nkpt))
         If (allocated(vkc)) deallocate (vkc)
         Allocate (vkc(3, nkpt))
         Do ik = 1, nkpt
            vkl (:, ik) = vplp1d (:, ik)
            Call r3mv (bvec, vkl(:, ik), vkc(:, ik))
         End Do
      Else If (task .Eq. 25) Then
! effective mass calculation
         nkpt = (2*input%properties%masstensor%ndspem+1) ** 3
         If (allocated(ivk)) deallocate (ivk)
         Allocate (ivk(3, nkpt))
         If (allocated(vkl)) deallocate (vkl)
         Allocate (vkl(3, nkpt))
         If (allocated(vkc)) deallocate (vkc)
         Allocate (vkc(3, nkpt))
! map vector to [0,1)
         Call r3frac (input%structure%epslat, &
        & input%properties%masstensor%vklem, iv)
         ik = 0
         Do i3 = - input%properties%masstensor%ndspem, &
        & input%properties%masstensor%ndspem
            Do i2 = - input%properties%masstensor%ndspem, &
           & input%properties%masstensor%ndspem
               Do i1 = - input%properties%masstensor%ndspem, &
              & input%properties%masstensor%ndspem
                  ik = ik + 1
                  ivk (1, ik) = i1
                  ivk (2, ik) = i2
                  ivk (3, ik) = i3
                  vc (1) = dble (i1)
                  vc (2) = dble (i2)
                  vc (3) = dble (i3)
                  vc (:) = vc (:) * input%properties%masstensor%deltaem
                  Call r3mv (binv, vc, vl)
                  vkl (:, ik) = input%properties%masstensor%vklem(:) + &
                 & vl (:)
                  Call r3mv (bvec, vkl(:, ik), vkc(:, ik))
               End Do
            End Do
         End Do
      Else
! determine the k-point grid automatically from radkpt if required
         If (input%groundstate%autokpt) Then
            input%groundstate%ngridk (:) = Int &
           & (input%groundstate%radkpt/&
           & Sqrt(input%structure%crystal%basevect(1, :)**2+&
           & input%structure%crystal%basevect(2, :)**2+&
           & input%structure%crystal%basevect(3, :)**2)) + 1
         End If
! if nktot is set (gt 0), determine the k-point grid automatically from nktot, 
! the total number of k-points
         If (input%groundstate%nktot.gt.0) Then
            blen(:)=sqrt(bvec(1,:)**2+bvec(2,:)**2+bvec(3,:)**2)           
            lambdab=Dble((input%groundstate%nktot/(blen(1)*blen(2)*blen(3)))**(1.d0/3.d0))
            input%groundstate%ngridk (:) = Max0(1,Int &
           & (lambdab*blen(:)+	input%structure%epslat))
             write(*,*) "ngridk determined from nktot: ", input%groundstate%ngridk(:)
         End If
! allocate the reduced k-point set arrays
         If (allocated(ivk)) deallocate (ivk)
         Allocate (ivk(3, input%groundstate%ngridk(1)*&
        & input%groundstate%ngridk(2)*input%groundstate%ngridk(3)))
         If (allocated(vkl)) deallocate (vkl)
         Allocate (vkl(3, input%groundstate%ngridk(1)*&
        & input%groundstate%ngridk(2)*input%groundstate%ngridk(3)))
         If (allocated(vkc)) deallocate (vkc)
         Allocate (vkc(3, input%groundstate%ngridk(1)*&
        & input%groundstate%ngridk(2)*input%groundstate%ngridk(3)))
         If (allocated(wkpt)) deallocate (wkpt)
         Allocate (wkpt(input%groundstate%ngridk(1)*&
        & input%groundstate%ngridk(2)*input%groundstate%ngridk(3)))
         If (allocated(ikmap)) deallocate (ikmap)
         Allocate (ikmap(0:input%groundstate%ngridk(1)-1, &
        & 0:input%groundstate%ngridk(2)-1, &
        & 0:input%groundstate%ngridk(3)-1))
! generate the reduced k-point set
         Call genppts (input%groundstate%reducek, .False., &
        & input%groundstate%ngridk, boxl, nkpt, ikmap, ivk, vkl, vkc, &
        & wkpt)
! allocate the non-reduced k-point set arrays
         nkptnr = input%groundstate%ngridk(1) * &
        & input%groundstate%ngridk(2) * input%groundstate%ngridk(3)
         If (allocated(ivknr)) deallocate (ivknr)
         Allocate (ivknr(3, nkptnr))
         If (allocated(vklnr)) deallocate (vklnr)
         Allocate (vklnr(3, nkptnr))
         If (allocated(vkcnr)) deallocate (vkcnr)
         Allocate (vkcnr(3, nkptnr))
         If (allocated(wkptnr)) deallocate (wkptnr)
         Allocate (wkptnr(nkptnr))
         If (allocated(ikmapnr)) deallocate (ikmapnr)
         Allocate (ikmapnr(0:input%groundstate%ngridk(1)-1, &
        & 0:input%groundstate%ngridk(2)-1, &
        & 0:input%groundstate%ngridk(3)-1))
! generate the non-reduced k-point set
         Call genppts (.False., .False., input%groundstate%ngridk, &
        & boxl, nkptnr, ikmapnr, ivknr, vklnr, vkcnr, wkptnr)
#ifdef TETRA
  ! call to module routine
         If (associated(input%xs)) Then
            If (associated(input%xs%tetra)) Then
               If (input%xs%tetra%tetraocc .Or. tetraopt .Or. &
              & input%xs%tetra%tetradf) Then
                  Call genkpts_tet (filext, input%structure%epslat, &
                 & bvec, maxsymcrys, nsymcrys, lsplsymc, symlat, &
                 & input%groundstate%reducek, input%groundstate%ngridk, &
                 & input%groundstate%vkloff, nkpt, ikmap, vkl, wkpt)
               End If
            End If
         End If
#endif
#ifdef XS
  ! determine inverse symmery elements
         Call findsymi (input%structure%epslat, maxsymcrys, nsymcrys, &
        & symlat, lsplsymc, vtlsymc, isymlat, scimap)
#endif
      End If
!
!---------------------!
!     G+k vectors     !
!---------------------!
! determine gkmax
      If ((input%groundstate%isgkmax .Ge. 1) .And. &
     & (input%groundstate%isgkmax .Le. nspecies)) Then
         gkmax = input%groundstate%rgkmax / rmt &
        & (input%groundstate%isgkmax)
      Else
         gkmax = input%groundstate%rgkmax / 2.d0
      End If
      If (2.d0*gkmax .Gt. &
     & input%groundstate%gmaxvr+input%structure%epslat) Then
         Write (*,*)
         Write (*, '("Error(init1): 2*gkmax > gmaxvr  ", 2G18.10)') &
        & 2.d0 * gkmax, input%groundstate%gmaxvr
         Write (*,*)
         Stop
      End If
! find the maximum number of G+k-vectors
      Call getngkmax
! allocate the G+k-vector arrays
      If (allocated(ngk)) deallocate (ngk)
      Allocate (ngk(nspnfv, nkpt))
      If (allocated(igkig)) deallocate (igkig)
      Allocate (igkig(ngkmax, nspnfv, nkpt))
      If (allocated(vgkl)) deallocate (vgkl)
      Allocate (vgkl(3, ngkmax, nspnfv, nkpt))
      If (allocated(vgkc)) deallocate (vgkc)
      Allocate (vgkc(3, ngkmax, nspnfv, nkpt))
      If (allocated(gkc)) deallocate (gkc)
      Allocate (gkc(ngkmax, nspnfv, nkpt))
      If (allocated(tpgkc)) deallocate (tpgkc)
      Allocate (tpgkc(2, ngkmax, nspnfv, nkpt))
      If (allocated(sfacgk)) deallocate (sfacgk)
      Allocate (sfacgk(ngkmax, natmtot, nspnfv, nkpt))
      Do ik = 1, nkpt
         Do ispn = 1, nspnfv
            If (isspinspiral()) Then
! spin-spiral case
               If (ispn .Eq. 1) Then
                  vl (:) = vkl (:, ik) + 0.5d0 * &
                 & input%groundstate%spin%vqlss(:)
                  vc (:) = vkc (:, ik) + 0.5d0 * vqcss (:)
               Else
                  vl (:) = vkl (:, ik) - 0.5d0 * &
                 & input%groundstate%spin%vqlss(:)
                  vc (:) = vkc (:, ik) - 0.5d0 * vqcss (:)
               End If
            Else
               vl (:) = vkl (:, ik)
               vc (:) = vkc (:, ik)
            End If
! generate the G+k-vectors
            Call gengpvec (vl, vc, ngk(ispn, ik), igkig(:, ispn, ik), &
           & vgkl(:, :, ispn, ik), vgkc(:, :, ispn, ik), gkc(:, ispn, &
           & ik), tpgkc(:, :, ispn, ik))
! generate structure factors for G+k-vectors
            Call gensfacgp (ngk(ispn, ik), vgkc(:, :, ispn, ik), &
           & ngkmax, sfacgk(:, :, ispn, ik))
         End Do
      End Do
!
#ifdef XS
      If (init1norealloc) Go To 10
#endif
!---------------------------------!
!     APWs and local-orbitals     !
!---------------------------------!
! allocate linearisation energy arrays
      If (allocated(apwe)) deallocate (apwe)
      Allocate (apwe(maxapword, 0:input%groundstate%lmaxapw, natmtot))
      If (allocated(lorbe)) deallocate (lorbe)
      Allocate (lorbe(maxlorbord, maxlorb, natmtot))
      nlomax = 0
      lolmax = 0
      apwordmax = 0
      Do is = 1, nspecies
! find the maximum APW order
         Do l1 = 0, input%groundstate%lmaxapw
            apwordmax = Max (apwordmax, apword(l1, is))
         End Do
! set the APW linearisation energies to the default
         Do ia = 1, natoms (is)
            ias = idxas (ia, is)
            Do l1 = 0, input%groundstate%lmaxapw
               Do io = 1, apword (l1, is)
                  apwe (io, l1, ias) = apwe0 (io, l1, is)
               End Do
            End Do
         End Do
! find the maximum number of local-orbitals
         nlomax = Max (nlomax, nlorb(is))
! set the local-orbital linearisation energies to the default
         Do ia = 1, natoms (is)
            ias = idxas (ia, is)
            Do ilo = 1, nlorb (is)
               lolmax = Max (lolmax, lorbl(ilo, is))
               Do io = 1, lorbord (ilo, is)
                  lorbe (io, ilo, ias) = lorbe0 (io, ilo, is)
               End Do
            End Do
         End Do
      End Do
      lolmmax = (lolmax+1) ** 2
! generate the local-orbital index
      Call genidxlo
! allocate radial function arrays
      If (allocated(apwfr)) deallocate (apwfr)
      Allocate (apwfr(nrmtmax, 2, apwordmax, &
     & 0:input%groundstate%lmaxapw, natmtot))
      If (allocated(apwdfr)) deallocate (apwdfr)
      Allocate (apwdfr(apwordmax, 0:input%groundstate%lmaxapw, &
     & natmtot))
      If (allocated(lofr)) deallocate (lofr)
      Allocate (lofr(nrmtmax, 2, nlomax, natmtot))
#ifdef XS
10    Continue
#endif
!
!------------------------------------!
!     secular equation variables     !
!------------------------------------!
! number of first-variational states
      nstfv = Int (chgval/2.d0) + input%groundstate%nempty + 1
! overlap and Hamiltonian matrix sizes
      If (allocated(nmat)) deallocate (nmat)
      Allocate (nmat(nspnfv, nkpt))
      If (allocated(npmat)) deallocate (npmat)
      Allocate (npmat(nspnfv, nkpt))
      nmatmax = 0
      Do ik = 1, nkpt
         Do ispn = 1, nspnfv
            nmat (ispn, ik) = ngk (ispn, ik) + nlotot
            nmatmax = Max (nmatmax, nmat(ispn, ik))
! packed matrix sizes
            npmat (ispn, ik) = (nmat(ispn, ik)*(nmat(ispn, ik)+1)) / 2
! the number of first-variational states should not exceed the matrix size
            nstfv = Min (nstfv, nmat(ispn, ik))
         End Do
      End Do
! number of second-variational states
      nstsv = nstfv * nspinor
#ifdef XS
      If (init1norealloc) Go To 20
#endif
! allocate second-variational arrays
      If (allocated(evalsv)) deallocate (evalsv)
      Allocate (evalsv(nstsv, nkpt))
      If (allocated(occsv)) deallocate (occsv)
      Allocate (occsv(nstsv, nkpt))
      occsv (:, :) = 0.d0
#ifdef XS
      If (allocated(occsv0)) deallocate (occsv0)
      Allocate (occsv0(nstsv, nkpt))
      occsv (:, :) = 0.d0
      If (allocated(isto0)) deallocate (isto0)
      Allocate (isto0(nkpt))
      isto0 (:) = 0.d0
      If (allocated(isto)) deallocate (isto)
      Allocate (isto(nkpt))
      isto (:) = 0.d0
      If (allocated(istu0)) deallocate (istu0)
      Allocate (istu0(nkpt))
      istu0 (:) = 0.d0
      If (allocated(istu)) deallocate (istu)
      Allocate (istu(nkpt))
      istu (:) = 0.d0
#endif
! allocate overlap and Hamiltonian integral arrays
      If (allocated(oalo)) deallocate (oalo)
      Allocate (oalo(apwordmax, nlomax, natmtot))
      If (allocated(ololo)) deallocate (ololo)
      Allocate (ololo(nlomax, nlomax, natmtot))
      If (allocated(haa)) deallocate (haa)
      Allocate (haa(apwordmax, 0:input%groundstate%lmaxmat, apwordmax, &
     & 0:input%groundstate%lmaxapw, lmmaxvr, natmtot))
      If (allocated(hloa)) deallocate (hloa)
      Allocate (hloa(nlomax, apwordmax, 0:input%groundstate%lmaxmat, &
     & lmmaxvr, natmtot))
      If (allocated(hlolo)) deallocate (hlolo)
      Allocate (hlolo(nlomax, nlomax, lmmaxvr, natmtot))
! allocate and generate complex Gaunt coefficient array
      If (allocated(gntyry)) deallocate (gntyry)
      Allocate (gntyry(lmmaxmat, lmmaxvr, lmmaxapw))
      Do l1 = 0, input%groundstate%lmaxmat
         Do m1 = - l1, l1
            lm1 = idxlm (l1, m1)
            Do l2 = 0, input%groundstate%lmaxvr
               Do m2 = - l2, l2
                  lm2 = idxlm (l2, m2)
                  Do l3 = 0, input%groundstate%lmaxapw
                     Do m3 = - l3, l3
                        lm3 = idxlm (l3, m3)
                        gntyry (lm1, lm2, lm3) = gauntyry (l1, l2, l3, &
                       & m1, m2, m3)
                     End Do
                  End Do
               End Do
            End Do
         End Do
      End Do
#ifdef XS
20    Continue
! partial charges
  if (allocated(chgpart)) deallocate(chgpart)
  allocate(chgpart(lmmaxvr,natmtot,nstsv))
  chgpart(:,:,:)=0.d0
#endif
!
      Call timesec (ts1)
      timeinit = timeinit + ts1 - ts0
!
      Return
End Subroutine
!EOC
