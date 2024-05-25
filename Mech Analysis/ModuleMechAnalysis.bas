Attribute VB_Name = "ModuleMechAnalysis"
Option Explicit
Dim ErrorLocation As String
Dim MsgString As String

'Links to solid mechanics calls within MechAnalysis DLL
Private Declare PtrSafe Function CGetNormalStrain_xxFromStressTensor _
    Lib "MechAnalysis.dll" _
    (ByVal normalstress_xx As Double, ByVal normalstress_yy As Double, ByVal normalstress_zz As Double, _
    ByVal shearstress_xy As Double, ByVal shearstress_xz As Double, ByVal shearstress_yz As Double, _
    ByVal modulus As Double, ByVal poissons As Double, ByRef normalstrain_xx As Double) As Boolean

Private Declare PtrSafe Function CGetNormalStrain_yyFromStressTensor _
    Lib "MechAnalysis.dll" _
    (ByVal normalstress_xx As Double, ByVal normalstress_yy As Double, ByVal normalstress_zz As Double, _
    ByVal shearstress_xy As Double, ByVal shearstress_xz As Double, ByVal shearstress_yz As Double, _
    ByVal modulus As Double, ByVal poissons As Double, ByRef normalstrain_yy As Double) As Boolean

Private Declare PtrSafe Function CGetNormalStrain_zzFromStressTensor _
    Lib "MechAnalysis.dll" _
    (ByVal normalstress_xx As Double, ByVal normalstress_yy As Double, ByVal normalstress_zz As Double, _
    ByVal shearstress_xy As Double, ByVal shearstress_xz As Double, ByVal shearstress_yz As Double, _
    ByVal modulus As Double, ByVal poissons As Double, ByRef normalstrain_zz As Double) As Boolean

Private Declare PtrSafe Function CGetShearStrain_xyFromStressTensor _
    Lib "MechAnalysis.dll" _
    (ByVal normalstress_xx As Double, ByVal normalstress_yy As Double, ByVal normalstress_zz As Double, _
    ByVal shearstress_xy As Double, ByVal shearstress_xz As Double, ByVal shearstress_yz As Double, _
    ByVal modulus As Double, ByVal poissons As Double, ByRef shearstrain_xy As Double) As Boolean

Private Declare PtrSafe Function CGetShearStrain_xzFromStressTensor _
    Lib "MechAnalysis.dll" _
    (ByVal normalstress_xx As Double, ByVal normalstress_yy As Double, ByVal normalstress_zz As Double, _
    ByVal shearstress_xy As Double, ByVal shearstress_xz As Double, ByVal shearstress_yz As Double, _
    ByVal modulus As Double, ByVal poissons As Double, ByRef shearstrain_xz As Double) As Boolean

Private Declare PtrSafe Function CGetShearStrain_yzFromStressTensor _
    Lib "MechAnalysis.dll" _
    (ByVal normalstress_xx As Double, ByVal normalstress_yy As Double, ByVal normalstress_zz As Double, _
    ByVal shearstress_xy As Double, ByVal shearstress_xz As Double, ByVal shearstress_yz As Double, _
    ByVal modulus As Double, ByVal poissons As Double, ByRef shearstrain_yz As Double) As Boolean

Private Declare PtrSafe Function CGetStrainPrincipal_1 _
    Lib "MechAnalysis.dll" _
    (ByVal normalstrain_xx As Double, ByVal normalstrain_yy As Double, ByVal normalstrain_zz As Double, _
    ByVal shearstrain_xy As Double, ByVal shearstrain_xz As Double, ByVal shearstrain_yz As Double, _
    ByRef principal_1 As Double) As Boolean

Private Declare PtrSafe Function CGetStrainPrincipal_2 _
    Lib "MechAnalysis.dll" _
    (ByVal normalstrain_xx As Double, ByVal normalstrain_yy As Double, ByVal normalstrain_zz As Double, _
    ByVal shearstrain_xy As Double, ByVal shearstrain_xz As Double, ByVal shearstrain_yz As Double, _
    ByRef principal_2 As Double) As Boolean

Private Declare PtrSafe Function CGetStrainPrincipal_3 _
    Lib "MechAnalysis.dll" _
    (ByVal normalstrain_xx As Double, ByVal normalstrain_yy As Double, ByVal normalstrain_zz As Double, _
    ByVal shearstrain_xy As Double, ByVal shearstrain_xz As Double, ByVal shearstrain_yz As Double, _
    ByRef principal_3 As Double) As Boolean

Private Declare PtrSafe Function CGetNormalStress_xxFromStrainTensor _
    Lib "MechAnalysis.dll" _
    (ByVal normalstrain_xx As Double, ByVal normalstrain_yy As Double, ByVal normalstrain_zz As Double, _
    ByVal shearstrain_xy As Double, ByVal shearstrain_xz As Double, ByVal shearstrain_yz As Double, _
    ByVal modulus As Double, ByVal poissons As Double, ByRef normalstress_xx As Double) As Boolean

Private Declare PtrSafe Function CGetNormalStress_yyFromStrainTensor _
    Lib "MechAnalysis.dll" _
    (ByVal normalstrain_xx As Double, ByVal normalstrain_yy As Double, ByVal normalstrain_zz As Double, _
    ByVal shearstrain_xy As Double, ByVal shearstrain_xz As Double, ByVal shearstrain_yz As Double, _
    ByVal modulus As Double, ByVal poissons As Double, ByRef normalstress_yy As Double) As Boolean

Private Declare PtrSafe Function CGetNormalStress_zzFromStrainTensor _
    Lib "MechAnalysis.dll" _
    (ByVal normalstrain_xx As Double, ByVal normalstrain_yy As Double, ByVal normalstrain_zz As Double, _
    ByVal shearstrain_xy As Double, ByVal shearstrain_xz As Double, ByVal shearstrain_yz As Double, _
    ByVal modulus As Double, ByVal poissons As Double, ByRef normalstress_zz As Double) As Boolean

Private Declare PtrSafe Function CGetShearStress_xyFromStrainTensor _
    Lib "MechAnalysis.dll" _
    (ByVal normalstrain_xx As Double, ByVal normalstrain_yy As Double, ByVal normalstrain_zz As Double, _
    ByVal shearstrain_xy As Double, ByVal shearstrain_xz As Double, ByVal shearstrain_yz As Double, _
    ByVal modulus As Double, ByVal poissons As Double, ByRef shearstress_xy As Double) As Boolean

Private Declare PtrSafe Function CGetShearStress_xzFromStrainTensor _
    Lib "MechAnalysis.dll" _
    (ByVal normalstrain_xx As Double, ByVal normalstrain_yy As Double, ByVal normalstrain_zz As Double, _
    ByVal shearstrain_xy As Double, ByVal shearstrain_xz As Double, ByVal shearstrain_yz As Double, _
    ByVal modulus As Double, ByVal poissons As Double, ByRef shearstress_xz As Double) As Boolean

Private Declare PtrSafe Function CGetShearStress_yzFromStrainTensor _
    Lib "MechAnalysis.dll" _
    (ByVal normalstrain_xx As Double, ByVal normalstrain_yy As Double, ByVal normalstrain_zz As Double, _
    ByVal shearstrain_xy As Double, ByVal shearstrain_xz As Double, ByVal shearstrain_yz As Double, _
    ByVal modulus As Double, ByVal poissons As Double, ByRef shearstress_yz As Double) As Boolean

Private Declare PtrSafe Function CGetStressPrincipal_1 _
    Lib "MechAnalysis.dll" _
    (ByVal normalstrain_xx As Double, ByVal normalstrain_yy As Double, ByVal normalstrain_zz As Double, _
    ByVal shearstrain_xy As Double, ByVal shearstrain_xz As Double, ByVal shearstrain_yz As Double, _
    ByRef principal_1 As Double) As Boolean

Private Declare PtrSafe Function CGetStressPrincipal_2 _
    Lib "MechAnalysis.dll" _
    (ByVal normalstrain_xx As Double, ByVal normalstrain_yy As Double, ByVal normalstrain_zz As Double, _
    ByVal shearstrain_xy As Double, ByVal shearstrain_xz As Double, ByVal shearstrain_yz As Double, _
    ByRef principal_2 As Double) As Boolean

Private Declare PtrSafe Function CGetStressPrincipal_3 _
    Lib "MechAnalysis.dll" _
    (ByVal normalstrain_xx As Double, ByVal normalstrain_yy As Double, ByVal normalstrain_zz As Double, _
    ByVal shearstrain_xy As Double, ByVal shearstrain_xz As Double, ByVal shearstrain_yz As Double, _
    ByRef principal_3 As Double) As Boolean


'Links to applied dynamics calls within MechAnalysis DLL
Private Declare PtrSafe Function CDisplacement_USCS _
    Lib "MechAnalysis.dll" _
    (ByVal stroke As Double, ByVal l As Double, ByVal CrankAngleDegrees As Double) As Double

Private Declare PtrSafe Function CConnRodAngle_Degrees _
    Lib "MechAnalysis.dll" _
    (ByVal stroke As Double, ByVal l As Double, ByVal CrankAngleDegrees As Double) As Double
    
Private Declare PtrSafe Function CVelocity_USCS _
    Lib "MechAnalysis.dll" _
    (ByVal stroke As Double, _
     ByVal l As Double, _
     ByVal CrankAngleDegrees As Double, _
     ByVal RPM As Double) As Double
     
Private Declare PtrSafe Function CAcceleration_USCS _
    Lib "MechAnalysis.dll" _
    (ByVal stroke As Double, _
     ByVal l As Double, _
     ByVal CrankAngleDegrees As Double, _
     ByVal RPM As Double) As Double
     
Private Declare PtrSafe Function CGasLoad_USCS _
    Lib "MechAnalysis.dll" _
    (ByVal stroke As Double, _
     ByVal l As Double, _
     ByVal CrankAngleDegrees As Double, _
     ByVal RPM As Double, _
     ByVal PistonAreaCrankEnd_01 As Double, _
     ByVal PistonAreaHeadEnd_01 As Double, _
     ByVal PistonAreaCrankEnd_02 As Double, _
     ByVal PistonAreaHeadEnd_02 As Double, _
     ByVal PressureGageCrankEnd_01 As Double, _
     ByVal PressureGageHeadEnd_01 As Double, _
     ByVal PressureGageCrankEnd_02 As Double, _
     ByVal PressureGageHeadEnd_02 As Double, _
     ByVal AmbientPressure As Double, _
     ByVal PistonAssyMass As Double, _
     ByVal CrossheadMass As Double, _
     ByVal ConnRodSmallEndMass As Double, _
     ByVal ConnRodLargeEndMass As Double, _
     ByVal CCW As Boolean, _
     ByVal Right As Boolean) As Double

Private Declare PtrSafe Function CInertiaLoad_USCS _
    Lib "MechAnalysis.dll" _
    (ByVal stroke As Double, _
     ByVal l As Double, _
     ByVal CrankAngleDegrees As Double, _
     ByVal RPM As Double, _
     ByVal PistonAssyMass As Double, _
     ByVal CrossheadMass As Double) As Double

Private Declare PtrSafe Function CCombinedLoad_USCS _
    Lib "MechAnalysis.dll" _
    (ByVal stroke As Double, _
     ByVal l As Double, _
     ByVal CrankAngleDegrees As Double, _
     ByVal RPM As Double, _
     ByVal PistonAreaCrankEnd_01 As Double, _
     ByVal PistonAreaHeadEnd_01 As Double, _
     ByVal PistonAreaCrankEnd_02 As Double, _
     ByVal PistonAreaHeadEnd_02 As Double, _
     ByVal PressureGageCrankEnd_01 As Double, _
     ByVal PressureGageHeadEnd_01 As Double, _
     ByVal PressureGageCrankEnd_02 As Double, _
     ByVal PressureGageHeadEnd_02 As Double, _
     ByVal AmbientPressure As Double, _
     ByVal PistonAssyMass As Double, _
     ByVal CrossheadMass As Double, _
     ByVal ConnRodSmallEndMass As Double, _
     ByVal ConnRodLargeEndMass As Double, _
     ByVal CCW As Boolean, _
     ByVal Right As Boolean) As Double

Private Declare PtrSafe Function CVerticalForce_USCS _
    Lib "MechAnalysis.dll" _
    (ByVal stroke As Double, _
     ByVal l As Double, _
     ByVal CrankAngleDegrees As Double, _
     ByVal RPM As Double, _
     ByVal PistonAreaCrankEnd_01 As Double, _
     ByVal PistonAreaHeadEnd_01 As Double, _
     ByVal PistonAreaCrankEnd_02 As Double, _
     ByVal PistonAreaHeadEnd_02 As Double, _
     ByVal PressureGageCrankEnd_01 As Double, _
     ByVal PressureGageHeadEnd_01 As Double, _
     ByVal PressureGageCrankEnd_02 As Double, _
     ByVal PressureGageHeadEnd_02 As Double, _
     ByVal AmbientPressure As Double, _
     ByVal PistonAssyMass As Double, _
     ByVal CrossheadMass As Double, _
     ByVal ConnRodSmallEndMass As Double, _
     ByVal ConnRodLargeEndMass As Double, _
     ByVal CCW As Boolean, _
     ByVal Right As Boolean) As Double
          
Private Declare PtrSafe Function CMainBearingRadialForce_USCS _
    Lib "MechAnalysis.dll" _
    (ByVal stroke As Double, _
     ByVal l As Double, _
     ByVal CrankAngleDegrees As Double, _
     ByVal RPM As Double, _
     ByVal PistonAreaCrankEnd_01 As Double, _
     ByVal PistonAreaHeadEnd_01 As Double, _
     ByVal PistonAreaCrankEnd_02 As Double, _
     ByVal PistonAreaHeadEnd_02 As Double, _
     ByVal PressureGageCrankEnd_01 As Double, _
     ByVal PressureGageHeadEnd_01 As Double, _
     ByVal PressureGageCrankEnd_02 As Double, _
     ByVal PressureGageHeadEnd_02 As Double, _
     ByVal AmbientPressure As Double, _
     ByVal PistonAssyMass As Double, _
     ByVal CrossheadMass As Double, _
     ByVal ConnRodSmallEndMass As Double, _
     ByVal ConnRodLargeEndMass As Double, _
     ByVal CCW As Boolean, _
     ByVal Right As Boolean) As Double

Private Declare PtrSafe Function CMainBearingTangentialForce_USCS _
    Lib "MechAnalysis.dll" _
    (ByVal stroke As Double, _
     ByVal l As Double, _
     ByVal CrankAngleDegrees As Double, _
     ByVal RPM As Double, _
     ByVal PistonAreaCrankEnd_01 As Double, _
     ByVal PistonAreaHeadEnd_01 As Double, _
     ByVal PistonAreaCrankEnd_02 As Double, _
     ByVal PistonAreaHeadEnd_02 As Double, _
     ByVal PressureGageCrankEnd_01 As Double, _
     ByVal PressureGageHeadEnd_01 As Double, _
     ByVal PressureGageCrankEnd_02 As Double, _
     ByVal PressureGageHeadEnd_02 As Double, _
     ByVal AmbientPressure As Double, _
     ByVal PistonAssyMass As Double, _
     ByVal CrossheadMass As Double, _
     ByVal ConnRodSmallEndMass As Double, _
     ByVal ConnRodLargeEndMass As Double, _
     ByVal CCW As Boolean, _
     ByVal Right As Boolean) As Double

Private Declare PtrSafe Function CMainBearingTorque_USCS _
    Lib "MechAnalysis.dll" _
    (ByVal stroke As Double, _
     ByVal l As Double, _
     ByVal CrankAngleDegrees As Double, _
     ByVal RPM As Double, _
     ByVal PistonAreaCrankEnd_01 As Double, _
     ByVal PistonAreaHeadEnd_01 As Double, _
     ByVal PistonAreaCrankEnd_02 As Double, _
     ByVal PistonAreaHeadEnd_02 As Double, _
     ByVal PressureGageCrankEnd_01 As Double, _
     ByVal PressureGageHeadEnd_01 As Double, _
     ByVal PressureGageCrankEnd_02 As Double, _
     ByVal PressureGageHeadEnd_02 As Double, _
     ByVal AmbientPressure As Double, _
     ByVal PistonAssyMass As Double, _
     ByVal CrossheadMass As Double, _
     ByVal ConnRodSmallEndMass As Double, _
     ByVal ConnRodLargeEndMass As Double, _
     ByVal CCW As Boolean, _
     ByVal Right As Boolean) As Double
    
'-----------------------------------------------------------------------------------
' Solid mechanics calls below this marker
'-----------------------------------------------------------------------------------

Public Function XGetNormalStrain_xxFromStressTensor(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double, _
    modulus As Double, poissons As Double)

    On Error GoTo ErrorGetNormalStrain_xxFromStressTensor
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetNormalStrain_xxFromStressTensor(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, modulus, poissons, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetNormalStrain_xxFromStressTensor = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetNormalStrain_xxFromStressTensor", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetNormalStrain_xxFromStressTensor:
    ErrorLocation = "Error Executing CGetNormalStrain_xxFromStressTensor"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function
Public Function XGetNormalStrain_yyFromStressTensor(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double, _
    modulus As Double, poissons As Double)

    On Error GoTo ErrorGetNormalStrain_yyFromStressTensor
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetNormalStrain_yyFromStressTensor(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, modulus, poissons, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetNormalStrain_yyFromStressTensor = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetNormalStrain_yyFromStressTensor", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetNormalStrain_yyFromStressTensor:
    ErrorLocation = "Error Executing CGetNormalStrain_yyFromStressTensor"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function
Public Function XGetNormalStrain_zzFromStressTensor(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double, _
    modulus As Double, poissons As Double)

    On Error GoTo ErrorGetNormalStrain_zzFromStressTensor
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetNormalStrain_zzFromStressTensor(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, modulus, poissons, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetNormalStrain_zzFromStressTensor = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetNormalStrain_zzFromStressTensor", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetNormalStrain_zzFromStressTensor:
    ErrorLocation = "Error Executing CGetNormalStrain_zzFromStressTensor"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function
Public Function XGetShearStrain_xyFromStressTensor(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double, _
    modulus As Double, poissons As Double)

    On Error GoTo ErrorGetShearStrain_xyFromStressTensor
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetShearStrain_xyFromStressTensor(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, modulus, poissons, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetShearStrain_xyFromStressTensor = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetShearStrain_xyFromStressTensor", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetShearStrain_xyFromStressTensor:
    ErrorLocation = "Error Executing CGetShearStrain_xyFromStressTensor"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function
Public Function XGetShearStrain_xzFromStressTensor(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double, _
    modulus As Double, poissons As Double)

    On Error GoTo ErrorGetShearStrain_xzFromStressTensor
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetShearStrain_xzFromStressTensor(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, modulus, poissons, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetShearStrain_xzFromStressTensor = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetShearStrain_xzFromStressTensor", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetShearStrain_xzFromStressTensor:
    ErrorLocation = "Error Executing CGetShearStrain_xzFromStressTensor"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function
Public Function XGetShearStrain_yzFromStressTensor(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double, _
    modulus As Double, poissons As Double)

    On Error GoTo ErrorGetShearStrain_yzFromStressTensor
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetShearStrain_yzFromStressTensor(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, modulus, poissons, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetShearStrain_yzFromStressTensor = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetShearStrain_yzFromStressTensor", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetShearStrain_yzFromStressTensor:
    ErrorLocation = "Error Executing CGetShearStrain_yzFromStressTensor"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function
Public Function XGetStrainPrincipal_1(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double)

    On Error GoTo ErrorGetStrainPrincipal_1
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetStrainPrincipal_1(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetStrainPrincipal_1 = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetStrainPrincipal_1", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetStrainPrincipal_1:
    ErrorLocation = "Error Executing GetStrainPrincipal_1"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function
Public Function XGetStrainPrincipal_2(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double)

    On Error GoTo ErrorGetStrainPrincipal_2
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetStrainPrincipal_2(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetStrainPrincipal_2 = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetStrainPrincipal_2", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetStrainPrincipal_2:
    ErrorLocation = "Error Executing GetStrainPrincipal_2"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function

Public Function XGetStrainPrincipal_3(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double)

    On Error GoTo ErrorGetStrainPrincipal_3
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetStrainPrincipal_3(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetStrainPrincipal_3 = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetStrainPrincipal_3", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetStrainPrincipal_3:
    ErrorLocation = "Error Executing GetStrainPrincipal_3"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function
Public Function XGetNormalStress_xxFromStrainTensor(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double, _
    modulus As Double, poissons As Double)

    On Error GoTo ErrorGetNormalStress_xxFromStrainTensor
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetNormalStress_xxFromStrainTensor(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, modulus, poissons, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetNormalStress_xxFromStrainTensor = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetNormalStress_xxFromStrainTensor", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetNormalStress_xxFromStrainTensor:
    ErrorLocation = "Error Executing CGetNormalStress_xxFromStrainTensor"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function
Public Function XGetNormalStress_yyFromStrainTensor(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double, _
    modulus As Double, poissons As Double)

    On Error GoTo ErrorGetNormalStress_yyFromStrainTensor
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetNormalStress_yyFromStrainTensor(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, modulus, poissons, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetNormalStress_yyFromStrainTensor = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetNormalStress_yyFromStrainTensor", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetNormalStress_yyFromStrainTensor:
    ErrorLocation = "Error Executing CGetNormalStress_yyFromStrainTensor"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function
Public Function XGetNormalStress_zzFromStrainTensor(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double, _
    modulus As Double, poissons As Double)

    On Error GoTo ErrorGetNormalStress_zzFromStrainTensor
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetNormalStress_zzFromStrainTensor(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, modulus, poissons, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetNormalStress_zzFromStrainTensor = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetNormalStress_zzFromStrainTensor", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetNormalStress_zzFromStrainTensor:
    ErrorLocation = "Error Executing CGetNormalStress_zzFromStrainTensor"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function
Public Function XGetShearStress_xyFromStrainTensor(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double, _
    modulus As Double, poissons As Double)

    On Error GoTo ErrorGetShearStress_xyFromStrainTensor
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetShearStress_xyFromStrainTensor(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, modulus, poissons, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetShearStress_xyFromStrainTensor = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetShearStress_xyFromStrainTensor", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetShearStress_xyFromStrainTensor:
    ErrorLocation = "Error Executing CGetShearStress_xyFromStrainTensor"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function
Public Function XGetShearStress_xzFromStrainTensor(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double, _
    modulus As Double, poissons As Double)

    On Error GoTo ErrorGetShearStress_xzFromStrainTensor
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetShearStress_xzFromStrainTensor(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, modulus, poissons, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetShearStress_xzFromStrainTensor = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetShearStress_xzFromStrainTensor", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetShearStress_xzFromStrainTensor:
    ErrorLocation = "Error Executing CGetShearStress_xzFromStrainTensor"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function
Public Function XGetShearStress_yzFromStrainTensor(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double, _
    modulus As Double, poissons As Double)

    On Error GoTo ErrorGetShearStress_yzFromStrainTensor
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetShearStress_yzFromStrainTensor(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, modulus, poissons, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetShearStress_yzFromStrainTensor = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetShearStress_yzFromStrainTensor", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetShearStress_yzFromStrainTensor:
    ErrorLocation = "Error Executing CGetShearStress_yzFromStrainTensor"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function
Public Function XGetStressPrincipal_1(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double)

    On Error GoTo ErrorGetStressPrincipal_1
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetStressPrincipal_1(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetStressPrincipal_1 = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetStressPrincipal_1", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetStressPrincipal_1:
    ErrorLocation = "Error Executing GetStressPrincipal_1"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function
Public Function XGetStressPrincipal_2(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double)

    On Error GoTo ErrorGetStressPrincipal_2
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetStressPrincipal_2(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetStressPrincipal_2 = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetStressPrincipal_2", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetStressPrincipal_2:
    ErrorLocation = "Error Executing GetStressPrincipal_2"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function
Public Function XGetStressPrincipal_3(normal_xx As Double, normal_yy As Double, normal_zz As Double, _
    shear_xy As Double, shear_xz As Double, shear_yz As Double)

    On Error GoTo ErrorGetStressPrincipal_3
    
    'locals
    Dim flag As Boolean
    Dim dtemp As Double
    
    flag = CGetStressPrincipal_3(normal_xx, normal_yy, normal_zz, shear_xy, shear_xz, shear_yz, dtemp)
    
    'if no error codes are thrown, return the value
    If flag Then
        XGetStressPrincipal_3 = dtemp
    Else
        Err.Raise vbObjectError + 100, "XGetStressPrincipal_3", _
            "Calculation Failed"
    End If
    
    'Avoid Error handler
    Exit Function

ErrorGetStressPrincipal_3:
    ErrorLocation = "Error Executing GetStressPrincipal_3"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function


'-----------------------------------------------------------------------------------
' Applied dynamics calls below this marker
'-----------------------------------------------------------------------------------

Public Function XDisplacement_USCS(stroke As Double, l As Double, CrankAngleDegrees As Double)

    On Error GoTo ErrorXDisplacement_USCS
    
    XDisplacement_USCS = CDisplacement_USCS(stroke, l, CrankAngleDegrees)
    
    'Avoid Error handler
    Exit Function

ErrorXDisplacement_USCS:
    ErrorLocation = "Error Executing CDisplacement_USCS DLL"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function

Public Function XVelocity_USCS(stroke As Double, _
                            l As Double, _
                            CrankAngleDegrees As Double, _
                            RPM As Double)

    On Error GoTo ErrorXVelocity_USCS
    
    XVelocity_USCS = CVelocity_USCS(stroke, l, CrankAngleDegrees, RPM)
    
    'Avoid Error handler
    Exit Function

ErrorXVelocity_USCS:
    ErrorLocation = "Error Calling CVelocity_USCS DLL"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function

Public Function XAcceleration_USCS(stroke As Double, _
                            l As Double, _
                            CrankAngleDegrees As Double, _
                            RPM As Double)

    On Error GoTo ErrorXAcceleration_USCS
    
    XAcceleration_USCS = CAcceleration_USCS(stroke, l, CrankAngleDegrees, RPM)
    
    'Avoid Error handler
    Exit Function

ErrorXAcceleration_USCS:
    ErrorLocation = "Error Calling CAcceleration_USCS DLL"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function

Public Function XGasLoad_USCS(stroke As Double, l As Double, _
     CrankAngleDegrees As Double, _
     RPM As Double, _
     PistonAreaCrankEnd_01 As Double, _
     PistonAreaHeadEnd_01 As Double, _
     PistonAreaCrankEnd_02 As Double, _
     PistonAreaHeadEnd_02 As Double, _
     PressureGageCrankEnd_01 As Double, _
     PressureGageHeadEnd_01 As Double, _
     PressureGageCrankEnd_02 As Double, _
     PressureGageHeadEnd_02 As Double, _
     AmbientPressure As Double, _
     PistonAssyMass As Double, _
     CrossheadMass As Double, _
     ConnRodSmallEndMass As Double, _
     ConnRodLargeEndMass As Double, _
     CCW As Boolean, _
     Right As Boolean)

    On Error GoTo ErrorXGasLoad_USCS
    
    XGasLoad_USCS = CGasLoad_USCS(stroke, l, CrankAngleDegrees, RPM, _
     PistonAreaCrankEnd_01, _
     PistonAreaHeadEnd_01, _
     PistonAreaCrankEnd_02, _
     PistonAreaHeadEnd_02, _
     PressureGageCrankEnd_01, _
     PressureGageHeadEnd_01, _
     PressureGageCrankEnd_02, _
     PressureGageHeadEnd_02, _
     AmbientPressure, _
     PistonAssyMass, _
     CrossheadMass, _
     ConnRodSmallEndMass, _
     ConnRodLargeEndMass, _
     CCW, _
     Right)
    
    'Avoid Error handler
    Exit Function

ErrorXGasLoad_USCS:
    ErrorLocation = "Error Calling CGasLoad_USCS DLL"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function

Public Function XInertiaLoad_USCS(stroke As Double, l As Double, _
     CrankAngleDegrees As Double, _
     RPM As Double, _
     PistonAssyMass As Double, _
     CrossheadMass As Double)

    On Error GoTo ErrorXInertiaLoad_USCS
    
    XInertiaLoad_USCS = CInertiaLoad_USCS(stroke, l, CrankAngleDegrees, RPM, _
     PistonAssyMass, _
     CrossheadMass)
    
    'Avoid Error handler
    Exit Function

ErrorXInertiaLoad_USCS:
    ErrorLocation = "Error Calling CInertiaLoad_USCS DLL"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function

Public Function XCombinedLoad_USCS(stroke As Double, l As Double, _
     CrankAngleDegrees As Double, _
     RPM As Double, _
     PistonAreaCrankEnd_01 As Double, _
     PistonAreaHeadEnd_01 As Double, _
     PistonAreaCrankEnd_02 As Double, _
     PistonAreaHeadEnd_02 As Double, _
     PressureGageCrankEnd_01 As Double, _
     PressureGageHeadEnd_01 As Double, _
     PressureGageCrankEnd_02 As Double, _
     PressureGageHeadEnd_02 As Double, _
     AmbientPressure As Double, _
     PistonAssyMass As Double, _
     CrossheadMass As Double, _
     ConnRodSmallEndMass As Double, _
     ConnRodLargeEndMass As Double, _
     CCW As Boolean, _
     Right As Boolean)

    On Error GoTo ErrorXCombinedLoad_USCS
    
    XCombinedLoad_USCS = CCombinedLoad_USCS(stroke, l, CrankAngleDegrees, RPM, _
     PistonAreaCrankEnd_01, _
     PistonAreaHeadEnd_01, _
     PistonAreaCrankEnd_02, _
     PistonAreaHeadEnd_02, _
     PressureGageCrankEnd_01, _
     PressureGageHeadEnd_01, _
     PressureGageCrankEnd_02, _
     PressureGageHeadEnd_02, _
     AmbientPressure, _
     PistonAssyMass, _
     CrossheadMass, _
     ConnRodSmallEndMass, _
     ConnRodLargeEndMass, _
     CCW, _
     Right)
    
    'Avoid Error handler
    Exit Function

ErrorXCombinedLoad_USCS:
    ErrorLocation = "Error Calling CCombinedLoad_USCS DLL"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function

Public Function XVerticalForce_USCS(stroke As Double, l As Double, _
     CrankAngleDegrees As Double, _
     RPM As Double, _
     PistonAreaCrankEnd_01 As Double, _
     PistonAreaHeadEnd_01 As Double, _
     PistonAreaCrankEnd_02 As Double, _
     PistonAreaHeadEnd_02 As Double, _
     PressureGageCrankEnd_01 As Double, _
     PressureGageHeadEnd_01 As Double, _
     PressureGageCrankEnd_02 As Double, _
     PressureGageHeadEnd_02 As Double, _
     AmbientPressure As Double, _
     PistonAssyMass As Double, _
     CrossheadMass As Double, _
     ConnRodSmallEndMass As Double, _
     ConnRodLargeEndMass As Double, _
     CCW As Boolean, _
     Right As Boolean)

    On Error GoTo ErrorXVerticalForce_USCS
    
    XVerticalForce_USCS = CVerticalForce_USCS(stroke, l, CrankAngleDegrees, RPM, _
     PistonAreaCrankEnd_01, _
     PistonAreaHeadEnd_01, _
     PistonAreaCrankEnd_02, _
     PistonAreaHeadEnd_02, _
     PressureGageCrankEnd_01, _
     PressureGageHeadEnd_01, _
     PressureGageCrankEnd_02, _
     PressureGageHeadEnd_02, _
     AmbientPressure, _
     PistonAssyMass, _
     CrossheadMass, _
     ConnRodSmallEndMass, _
     ConnRodLargeEndMass, _
     CCW, _
     Right)
    
    'Avoid Error handler
    Exit Function

ErrorXVerticalForce_USCS:
    ErrorLocation = "Error Calling CVerticalForce_USCS DLL"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function

Public Function XConnRodAngle_Degrees(stroke As Double, l As Double, CrankAngleDegrees As Double)

    On Error GoTo ErrorXConnRodAngle_Degrees
    
    XConnRodAngle_Degrees = CConnRodAngle_Degrees(stroke, l, CrankAngleDegrees)
    
    'Avoid Error handler
    Exit Function

ErrorXConnRodAngle_Degrees:
    ErrorLocation = "Error Executing CConnRodAngle_Degrees DLL"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function

End Function

Public Function XMainBearingRadialForce_USCS(stroke As Double, l As Double, _
     CrankAngleDegrees As Double, _
     RPM As Double, _
     PistonAreaCrankEnd_01 As Double, _
     PistonAreaHeadEnd_01 As Double, _
     PistonAreaCrankEnd_02 As Double, _
     PistonAreaHeadEnd_02 As Double, _
     PressureGageCrankEnd_01 As Double, _
     PressureGageHeadEnd_01 As Double, _
     PressureGageCrankEnd_02 As Double, _
     PressureGageHeadEnd_02 As Double, _
     AmbientPressure As Double, _
     PistonAssyMass As Double, _
     CrossheadMass As Double, _
     ConnRodSmallEndMass As Double, _
     ConnRodLargeEndMass As Double, _
     CCW As Boolean, _
     Right As Boolean)

    'Establish error handling
    On Error GoTo ErrorXMainBearingRadialForce_USCS
    
    XMainBearingRadialForce_USCS = CMainBearingRadialForce_USCS(stroke, l, CrankAngleDegrees, RPM, _
     PistonAreaCrankEnd_01, _
     PistonAreaHeadEnd_01, _
     PistonAreaCrankEnd_02, _
     PistonAreaHeadEnd_02, _
     PressureGageCrankEnd_01, _
     PressureGageHeadEnd_01, _
     PressureGageCrankEnd_02, _
     PressureGageHeadEnd_02, _
     AmbientPressure, _
     PistonAssyMass, _
     CrossheadMass, _
     ConnRodSmallEndMass, _
     ConnRodLargeEndMass, _
     CCW, _
     Right)
     
    'Avoid Error Handler
    Exit Function
    
ErrorXMainBearingRadialForce_USCS:
    ErrorLocation = "Error Executing XMainBearingRadialForce_USCS"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function
    
End Function

Public Function XMainBearingTangentialForce_USCS(stroke As Double, l As Double, _
     CrankAngleDegrees As Double, _
     RPM As Double, _
     PistonAreaCrankEnd_01 As Double, _
     PistonAreaHeadEnd_01 As Double, _
     PistonAreaCrankEnd_02 As Double, _
     PistonAreaHeadEnd_02 As Double, _
     PressureGageCrankEnd_01 As Double, _
     PressureGageHeadEnd_01 As Double, _
     PressureGageCrankEnd_02 As Double, _
     PressureGageHeadEnd_02 As Double, _
     AmbientPressure As Double, _
     PistonAssyMass As Double, _
     CrossheadMass As Double, _
     ConnRodSmallEndMass As Double, _
     ConnRodLargeEndMass As Double, _
     CCW As Boolean, _
     Right As Boolean)
     
    'Establish error handling
    On Error GoTo ErrorXMainBearingTangentialForce_USCS
    
    XMainBearingTangentialForce_USCS = CMainBearingTangentialForce_USCS(stroke, l, CrankAngleDegrees, RPM, _
     PistonAreaCrankEnd_01, _
     PistonAreaHeadEnd_01, _
     PistonAreaCrankEnd_02, _
     PistonAreaHeadEnd_02, _
     PressureGageCrankEnd_01, _
     PressureGageHeadEnd_01, _
     PressureGageCrankEnd_02, _
     PressureGageHeadEnd_02, _
     AmbientPressure, _
     PistonAssyMass, _
     CrossheadMass, _
     ConnRodSmallEndMass, _
     ConnRodLargeEndMass, _
     CCW, _
     Right)
    
    'Avoid Error Handler
    Exit Function
    
ErrorXMainBearingTangentialForce_USCS:
    ErrorLocation = "Error Executing XMainBearingTangentialForce_USCS"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function
    
End Function

Public Function XMainBearingTorque_USCS(stroke As Double, l As Double, _
     CrankAngleDegrees As Double, _
     RPM As Double, _
     PistonAreaCrankEnd_01 As Double, _
     PistonAreaHeadEnd_01 As Double, _
     PistonAreaCrankEnd_02 As Double, _
     PistonAreaHeadEnd_02 As Double, _
     PressureGageCrankEnd_01 As Double, _
     PressureGageHeadEnd_01 As Double, _
     PressureGageCrankEnd_02 As Double, _
     PressureGageHeadEnd_02 As Double, _
     AmbientPressure As Double, _
     PistonAssyMass As Double, _
     CrossheadMass As Double, _
     ConnRodSmallEndMass As Double, _
     ConnRodLargeEndMass As Double, _
     CCW As Boolean, _
     Right As Boolean)
     
    'Establish error handling
    On Error GoTo ErrorXMainBearingTorque_USCS
    
    XMainBearingTorque_USCS = CMainBearingTorque_USCS(stroke, l, CrankAngleDegrees, RPM, _
     PistonAreaCrankEnd_01, _
     PistonAreaHeadEnd_01, _
     PistonAreaCrankEnd_02, _
     PistonAreaHeadEnd_02, _
     PressureGageCrankEnd_01, _
     PressureGageHeadEnd_01, _
     PressureGageCrankEnd_02, _
     PressureGageHeadEnd_02, _
     AmbientPressure, _
     PistonAssyMass, _
     CrossheadMass, _
     ConnRodSmallEndMass, _
     ConnRodLargeEndMass, _
     CCW, _
     Right)
     
    'Avoid Error Handler
    Exit Function
    
ErrorXMainBearingTorque_USCS:
    ErrorLocation = "Error Executing XMainBearingTorque_USCS"
    MsgString = ErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox MsgString
    Exit Function
    
End Function


