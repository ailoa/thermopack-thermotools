module sutherland_a1
  !> The SAFT-VR Mie implementation of the first-order perturbation
  !> term a1 for the Sutherland potential, defined by u(r) =
  !> -eps*(sigma/r)**lambda. A hard-sphere reference system is used,
  !> which enters as the input x0=sigma/dhs

  !> Equation numbers refer to
  !> the SAFT-VR Mie paper by Lafitte et al. (2013).
  use hyperdual_mod
  implicit none

  public :: calc_a1_sutherland

contains

  !< Calculate first order perturbation term a1 of Ares/nRT (-)
  subroutine calc_a1_sutherland(x0,eta,lambda,eps,a1)
    ! Input
    type(hyperdual), intent(in) :: x0     !< Reduced center-center hard sphere distance
    type(hyperdual), intent(in) :: eta    !< Packing fraction (-)
    type(hyperdual), intent(in) :: lambda !< Sutherland exponent (-)
    type(hyperdual), intent(in) :: eps    !< Sutherland energy (K)
    ! Output
    type(hyperdual), intent(out) :: a1    !< First order perturbation term a1 ()
    ! Locals
    type(hyperdual) :: B
    type(hyperdual) :: as
    call calcA1_hardcore_sutherland(eta,lambda,eps,as)

    if (x0 > 1) then
       ! Calculate integral from d to sigma
       call calcB(x0,eta,lambda,eps,B)
    else
       ! Calculate integral from d to sigma elsewhere
       call stoperror("Not yet implemented")
    endif

    a1 = x0**lambda*(as+B)
  end subroutine calc_a1_sutherland


  !> Correlation integral from d to sigma, Eq33
  subroutine calcB(x0,eta,lambda,eps,B)
    ! Input
    type(hyperdual), intent(in) :: x0     !< Reduced center-center hard sphere distance
    type(hyperdual), intent(in) :: eta    !< Packing fraction (-)
    type(hyperdual), intent(in) :: lambda !< Sutherland exponent (-)
    type(hyperdual), intent(in) :: eps    !< Sutherland energy (K)
    ! Output
    type(hyperdual), intent(out) :: B
    ! Locals
    type(hyperdual) :: J,I,keta(2)
    type(hyperdual) :: denum3

    ! Calculate I_lambda (Eq28) and J_lambda (Eq29)
    I = - (x0**(3.0 - lambda) - 1.0)/(lambda - 3.0)
    J = - ((lambda - 3.0)*x0**(4.0 - lambda) - (lambda - 4.0)*x0**(3.0 - lambda) - 1.0)/&
         ((lambda - 3.0)*(lambda - 4.0))

    denum3 = (1.0-eta)**3
    keta(1) = (2.0-eta)/denum3
    keta(2) = -9.0*eta*(1.0+eta)/denum3
    B = 6.0*eta*eps*(keta(1)*I + keta(2)*J)
  end subroutine calcB

  !> Calculate utility function for the Helmholtz free energy of
  !> hard-core Sutherland particle
  subroutine calcEffEta(eta,lambda,ef)
    ! Input
    type(hyperdual), intent(in) :: eta    !< Packing fraction (-)
    type(hyperdual), intent(in) :: lambda !< Sutherland exponent (-)
    ! Output
    type(hyperdual), intent(out) :: ef
    ! Locals
    real, parameter :: lam_coeff(4,4) = reshape((/ 0.81096, 1.7888, -37.578, &
         92.284, 1.0205, -19.341, 151.26, -463.50, -1.9057, 22.845, -228.14, 973.92, &
         1.0885, -6.1962, 106.98, -677.64 /), (/4,4/))
    type(hyperdual) :: c(4), inv_lam(4)
    integer :: i
    inv_lam(1) = 1.0
    do i=2,4
       inv_lam(i) = inv_lam(i-1)/lambda
    enddo
    do i=1,4
       c(i) = sum(lam_coeff(:,i)*inv_lam)
    enddo
    ef = eta*(c(1) + eta*(c(2) + eta*(c(3) + eta*c(4))))
  end subroutine calcEffEta

  !> Correlation integral from d to infty, i.e. a1 for a hard-core
  !> Sutherland particle (Eq39)
  subroutine calcA1_hardcore_sutherland(eta,lambda,eps,a1s)
    ! Input
    type(hyperdual), intent(in) :: eta    !< Packing fraction (-)
    type(hyperdual), intent(in) :: lambda !< Sutherland exponent (-)
    type(hyperdual), intent(in) :: eps    !< Sutherland energy (K)
    ! Output
    type(hyperdual), intent(out) :: a1s
    ! Locals
    type(hyperdual) :: ef
    call calcEffEta(eta,lambda,ef)
    a1s = -12*eps*eta/(lambda-3.0) * (1.0 - 0.5*ef)/(1.0 - ef)**3
  end subroutine calcA1_hardcore_sutherland

end module sutherland_a1