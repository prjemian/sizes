	PROGRAM CreateTest	PARAMETER ( Pi = 3.141592653589793239 )	PARAMETER ( cmPerAng = 1.0E-8 )	PARAMETER ( contrast = 100.0 )	! * 10^20, 1/cm^4	PARAMETER ( Background = 0.1 )	! 1/cm^4	PARAMETER ( sMult = 1000. )	! counts per 1/cm (for shot noise)	PARAMETER ( sNoise = 0.025 )	! minimum level	!              Vf         rBar    std. dev.	PARAMETER ( a1 = 0.012, c1 =  75., s1 = 15. )	PARAMETER ( a2 = 0.008, c2 = 180., s2 = 60. )	PARAMETER ( NumIntensities = 91 )	PARAMETER ( hMin = 0.0042 )	! 1/A	PARAMETER ( hStep = 0.0003 )	PARAMETER ( hMult = 1.040 )	PARAMETER ( hDev = 0.022 )	PARAMETER ( NumRadii = 40 )	PARAMETER ( rMin = 25 )		! A	PARAMETER ( rStep = 5 )		! A	PARAMETER ( rMult = 1.03 )	REAL r(NumRadii), f(NumRadii), t(NumRadii)	REAL h(NumIntensities), s(NumIntensities), ds(NumIntensities)	DATA iSeed /12345/	! for random number generator	CALL OutWindowScroll (1000)	WRITE (*,*) 'Calculate the SAS intensity from'	WRITE (*,*) '    a test distribution.'	WRITE (*,*)	WRITE (*,*)  ' D,A   f,1/A'	r(1) = rMin		! make the <r> bins	f(1) = Bimodal (r(1), a1, c1, s1, a2, c2, s2)	WRITE (*,*) r(1), f(1)	DO i = 2, NumRadii	  r(i) = r(i-1) * rMult + rStep	  f(i) = Bimodal (r(i), a1, c1, s1, a2, c2, s2)	  WRITE (*,*) 2*r(i), 0.5*f(i)	END DO	WRITE (*,*)	! make the <h> bins (with a slightly uneven spacing)	h(1) = hMin*(1 + hDev*GASDEV(iSeed))	DO j = 2, NumIntensities	  h(j) = (h(j-1) * hMult + hStep)*(1 + hDev*GASDEV(iSeed))	END DO	! calculate the intensities	WRITE (*,*)  ' h,1/A   I,1/cm   dI,1/cm'	DO j = 1, NumIntensities	  DO i = 1, NumRadii		! evaluate the integrand	    hr = h(j) * r(i)	    Debye = (3/hr**3) * (SIN(hr) - hr*COS(hr))	    pVol = (4*Pi/3) * (r(i)*cmPerAng)**3	    t(i) = contrast*1.0E20 * Debye**2 * pVol * f(i)	  END DO	  signal = TrapD (r, t, NumRadii) + Background	  counts = signal * sMult		! how many counts?	  eps = SQRT( 1/counts + sNoise**2 )	! noise level	  ds(j) = signal * eps			! estimated error	  s(j) = signal + ds(j) * GASDEV(iSeed)	! add random error	  WRITE (*,*) h(j), s(j), ds(j)	END DO	WRITE (*,*)	END	FUNCTION Bimodal (x, a1, c1, s1, a2, c2, s2)	!	Prepare a bimodal volume fraction size 	!	distribution where each of the two peaks	!	is a log-normal volume fraction distribution.	!	x : sphere radius (x units)	!	a : volume fraction (1/x units)	!	c : peak center	(x units)	!	s : peak half-width (x units)	Bimodal = a1*GaussLog(x, c1, s1) + a2*GaussLog(x, c2, s2)	RETURN	END	FUNCTION TrapD (x, y, N)	! discrete trapezoid rule	REAL x(*), y(*)	a = 0.0	DO i = 2, N	  a = a + 0.5*( y(i) + y(i-1) )*( x(i) - x(i-1) )	END DO	TrapD = a	END	FUNCTION Gaussian (x, c, s)	! normal distribution	PARAMETER ( Root2Pi = 2.506628274631000502 )	GaussLog = 1/(s * Root2Pi) * EXP(-0.5*((x-c)/s)**2)	RETURN	END	FUNCTION GaussLog (x, c, s)	! log-normal distribution	PARAMETER ( Root2Pi = 2.506628274631000502 )	GaussLog = 1/(s * Root2Pi) * EXP(-0.5*(LOG(x/c)/(s/c))**2)	RETURN	END      FUNCTION GASDEV(IDUM)      DATA ISET/0/      IF (ISET.EQ.0) THEN1       V1=2.*RAN1(IDUM)-1.        V2=2.*RAN1(IDUM)-1.        R=V1**2+V2**2        IF(R.GE.1.)GO TO 1        FAC=SQRT(-2.*LOG(R)/R)        GSET=V1*FAC        GASDEV=V2*FAC        ISET=1      ELSE        GASDEV=GSET        ISET=0      ENDIF      RETURN      END      SUBROUTINE MIDINF(FUNK,AA,BB,S,N)      FUNC(X)=FUNK(1./X)/X**2      B=1./AA      A=1./BB      IF (N.EQ.1) THEN        S=(B-A)*FUNC(0.5*(A+B))        IT=1      ELSE        TNM=IT        DEL=(B-A)/(3.*TNM)        DDEL=DEL+DEL        X=A+0.5*DEL        SUM=0.        DO 11 J=1,IT          SUM=SUM+FUNC(X)          X=X+DDEL          SUM=SUM+FUNC(X)          X=X+DEL11      CONTINUE        S=(S+(B-A)*SUM/TNM)/3.        IT=3*IT      ENDIF      RETURN      END      SUBROUTINE MIDPNT(FUNC,A,B,S,N)      IF (N.EQ.1) THEN        S=(B-A)*FUNC(0.5*(A+B))        IT=1      ELSE        TNM=IT        DEL=(B-A)/(3.*TNM)        DDEL=DEL+DEL        X=A+0.5*DEL        SUM=0.        DO 11 J=1,IT          SUM=SUM+FUNC(X)          X=X+DDEL          SUM=SUM+FUNC(X)          X=X+DEL11      CONTINUE        S=(S+(B-A)*SUM/TNM)/3.        IT=3*IT      ENDIF      RETURN      END      SUBROUTINE POLINT(XA,YA,N,X,Y,DY)      PARAMETER (NMAX=10)       DIMENSION XA(N),YA(N),C(NMAX),D(NMAX)      NS=1      DIF=ABS(X-XA(1))      DO 11 I=1,N         DIFT=ABS(X-XA(I))        IF (DIFT.LT.DIF) THEN          NS=I          DIF=DIFT        ENDIF        C(I)=YA(I)        D(I)=YA(I)11    CONTINUE      Y=YA(NS)      NS=NS-1      DO 13 M=1,N-1        DO 12 I=1,N-M          HO=XA(I)-X          HP=XA(I+M)-X          W=C(I+1)-D(I)          DEN=HO-HP          IF(DEN.EQ.0.)PAUSE          DEN=W/DEN          D(I)=HP*DEN          C(I)=HO*DEN12      CONTINUE        IF (2*NS.LT.N-M)THEN          DY=C(NS+1)        ELSE          DY=D(NS)          NS=NS-1        ENDIF        Y=Y+DY13    CONTINUE      RETURN      END      SUBROUTINE QROMB (FUNC,A,B,SS)      PARAMETER(EPS=1.E-4,JMAX=20,JMAXP=JMAX+1,K=5,KM=4)      DIMENSION S(JMAXP),H(JMAXP)      H(1)=1.      DO 11 J=1,JMAX        CALL TRAPZD(FUNC,A,B,S(J),J)C	WRITE (*,*) 'DEBUG(QROMB): j, S(j):', j, s(j)        IF (J.GE.K) THEN          L=J-KM          CALL POLINT(H(L),S(L),K,0.,SS,DSS)C	WRITE (*,*) 'DEBUG(QROMB): SS, DSS:', SS,DSS          IF (ABS(DSS).LT.EPS*ABS(SS)) RETURN        ENDIF        S(J+1)=S(J)        H(J+1)=0.25*H(J)11    CONTINUE      PAUSE 'Too many steps.'      END      SUBROUTINE QROMO(FUNC,A,B,SS,CHOOSE)      PARAMETER (EPS=1.E-6,JMAX=14,JMAXP=JMAX+1,KM=4,K=KM+1)      DIMENSION S(JMAXP),H(JMAXP)      H(1)=1.      DO 11 J=1,JMAX        CALL CHOOSE(FUNC,A,B,S(J),J)        IF (J.GE.K) THEN          CALL POLINT(H(J-KM),S(J-KM),K,0.0,SS,DSS)          IF (ABS(DSS).LT.EPS*ABS(SS)) RETURN        ENDIF        S(J+1)=S(J)        H(J+1)=H(J)/9.11    CONTINUE      PAUSE 'Too many steps.'      END      FUNCTION RAN1(IDUM)      DIMENSION R(97)      PARAMETER (M1=259200,IA1=7141,IC1=54773,RM1=3.8580247E-6)      PARAMETER (M2=134456,IA2=8121,IC2=28411,RM2=7.4373773E-6)      PARAMETER (M3=243000,IA3=4561,IC3=51349)      DATA IFF /0/      IF (IDUM.LT.0.OR.IFF.EQ.0) THEN        IFF=1        IX1=MOD(IC1-IDUM,M1)        IX1=MOD(IA1*IX1+IC1,M1)        IX2=MOD(IX1,M2)        IX1=MOD(IA1*IX1+IC1,M1)        IX3=MOD(IX1,M3)        DO 11 J=1,97          IX1=MOD(IA1*IX1+IC1,M1)          IX2=MOD(IA2*IX2+IC2,M2)          R(J)=(FLOAT(IX1)+FLOAT(IX2)*RM2)*RM111      CONTINUE        IDUM=1      ENDIF      IX1=MOD(IA1*IX1+IC1,M1)      IX2=MOD(IA2*IX2+IC2,M2)      IX3=MOD(IA3*IX3+IC3,M3)      J=1+(97*IX3)/M3      IF(J.GT.97.OR.J.LT.1)PAUSE      RAN1=R(J)      R(J)=(FLOAT(IX1)+FLOAT(IX2)*RM2)*RM1      RETURN      END      SUBROUTINE TRAPZD(FUNC,A,B,S,N)      IF (N.EQ.1) THEN        S=0.5*(B-A)*(FUNC(A)+FUNC(B))        IT=1      ELSEC	WRITE (*,*) 'DEBUG(TRAPZD): IT:', IT        TNM=IT        DEL=(B-A)/TNM        X=A+0.5*DEL        SUM=0.        DO 11 J=1,IT          SUM=SUM+FUNC(X)          X=X+DEL11      CONTINUE        S=0.5*(S+(B-A)*SUM/TNM)        IT=2*IT      ENDIF      RETURN      END