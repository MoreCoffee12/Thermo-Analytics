Attribute VB_Name = "ModuleSignalProcessing"
'-----------------------------------------------------------------------------
' Copyright 2024 Robot Squirrel Productions.
'
'          (\_   _/)
'          ( o   o )
'          (  ^_^  )
'             \_/_
'
' Confidential and proprietary computer code and data.
'
' Copyright 2024 Robot Squirrel Productions.  All rights reserved. This
' computer code is proprietary to Robot Squirrel Productions and/or its
' affiliate(s) and may be covered by patents. It may not be used,
' disclosed, modified, transferred, or reproduced without prior written
' consent.
'-----------------------------------------------------------------------------
'
'-----------------------------------------------------------------------------
' Revision
'
' Modified to provided a waveform filtered to the corners contained within
' the record.
'
' Brian Howard
' 7 August 2012
'-----------------------------------------------------------------------------
' Revision
'
' Modified to provided AC-Coupled waveform conditioning
'
' Brian Howard
' 25 September 2012
'-----------------------------------------------------------------------------
' Revision
'
' Modified to add the function to caclulate waveform end matching statistics
'
' Brian Howard
' 9 October 2012
'-----------------------------------------------------------------------------
' Revision
'
' Modified to add waveform variance
'
' Brian Howard
' 17 October 2012
'-----------------------------------------------------------------------------
' Revision
'
' Modified to add ability to find the index of a peak value within a band
'
' Brian Howard
' 29 April 2013
'-----------------------------------------------------------------------------
' Revision
'
' Modified to support 64-bit VBA
'
' Brian Howard
' 4 April 2014
'-----------------------------------------------------------------------------
' Revision
'
' Modified to include new function:  bXGetStringFromArrayToRow
'
' Brian Howard
' 4 April 2014
'-----------------------------------------------------------------------------

'-----------------------------------------------------------------------------
' Avoid naming collisiions
Option Explicit
'-----------------------------------------------------------------------------

'-----------------------------------------------------------------------------
'Link to Signal Processing DLL
#If VBA7 Then
    Private Declare PtrSafe Function GetFFTMaxArraySize _
        Lib "SignalProcessing.dll" _
        () As Long
#Else
    Private Declare Function GetFFTMaxArraySize _
        Lib "SignalProcessing.dll" _
        () As Long
#End If

#If VBA7 Then
    Declare PtrSafe Function CalcFFT _
        Lib "SignalProcessing.dll" (dDataInArray As Double, _
                                dDataOutArray As Double, _
                                ByVal lArrayElementCount As Long, _
                                ByVal bSizeData As Boolean, _
                                ByVal lWindowType As Long) As Integer
#Else
    Declare Function CalcFFT _
        Lib "SignalProcessing.dll" (dDataInArray As Double, _
                                dDataOutArray As Double, _
                                ByVal lArrayElementCount As Long, _
                                ByVal bSizeData As Boolean, _
                                ByVal lWindowType As Long) As Integer
#End If

#If VBA7 Then
    Declare PtrSafe Function bCalcFFTReal _
        Lib "SignalProcessing.dll" (dDataInArray_Re As Double, _
                                dDataInArray_Im As Double, _
                                dDataOutArray_Amplitude As Double, _
                                dDataOutArray_Phase As Double, _
                                ByVal lArrayElementCount As Long, _
                                ByVal bSizeData As Boolean, _
                                ByVal lWindowType As Long) As Boolean
#Else
    Declare Function bCalcFFTReal _
        Lib "SignalProcessing.dll" (dDataInArray_Re As Double, _
                                dDataInArray_Im As Double, _
                                dDataOutArray_Amplitude As Double, _
                                dDataOutArray_Phase As Double, _
                                ByVal lArrayElementCount As Long, _
                                ByVal bSizeData As Boolean, _
                                ByVal lWindowType As Long) As Boolean
#End If

#If VBA7 Then
    Declare PtrSafe Function FilterWaveform _
        Lib "SignalProcessing.dll" (dDataInArray As Double, _
                                dDataOutArray As Double, _
                                ByVal lArrayElementCount As Long, _
                                ByVal bHighPass As Boolean, _
                                ByVal bLowPass As Boolean, _
                                ByVal bNotchPass As Boolean, _
                                ByVal bBandPass As Boolean, _
                                ByVal bIsZeroPhase As Boolean, _
                                ByVal dHPCorner As Double, _
                                ByVal dLPCorner As Double, _
                                ByVal dSamplingFrequency As Double, _
                                ByVal dPercentRipple As Double, _
                                ByVal lPoleCount As Long) As Integer
#Else
    Declare Function FilterWaveform _
        Lib "SignalProcessing.dll" (dDataInArray As Double, _
                                dDataOutArray As Double, _
                                ByVal lArrayElementCount As Long, _
                                ByVal bHighPass As Boolean, _
                                ByVal bLowPass As Boolean, _
                                ByVal bNotchPass As Boolean, _
                                ByVal bBandPass As Boolean, _
                                ByVal bIsZeroPhase As Boolean, _
                                ByVal dHPCorner As Double, _
                                ByVal dLPCorner As Double, _
                                ByVal dSamplingFrequency As Double, _
                                ByVal dPercentRipple As Double, _
                                ByVal lPoleCount As Long) As Integer
#End If

#If VBA7 Then
    Declare PtrSafe Function bXSmoothWaveform _
        Lib "SignalProcessing.dll" (dDataInArray As Double, _
                                dDataOutArray As Double, _
                                ByVal lArrayElementCount As Long, _
                                ByVal lHalfKernelLength As Long) As Boolean
#Else
    Declare Function bXSmoothWaveform _
        Lib "SignalProcessing.dll" (dDataInArray As Double, _
                                dDataOutArray As Double, _
                                ByVal lArrayElementCount As Long, _
                                ByVal lHalfKernelLength As Long) As Boolean
#End If
                            
#If VBA7 Then
    Declare PtrSafe Function bXSmoothWaveformMultiplePass _
        Lib "SignalProcessing.dll" (dDataInArray As Double, _
                                dDataOutArray As Double, _
                                ByVal lArrayElementCount As Long, _
                                ByVal lHalfKernelLength As Long, _
                                ByVal lNumberOfPasses As Long) As Boolean
#Else
    Declare Function bXSmoothWaveformMultiplePass _
        Lib "SignalProcessing.dll" (dDataInArray As Double, _
                                dDataOutArray As Double, _
                                ByVal lArrayElementCount As Long, _
                                ByVal lHalfKernelLength As Long, _
                                ByVal lNumberOfPasses As Long) As Boolean
#End If
                            
#If VBA7 Then
    Declare PtrSafe Function CalcWaveformRMS _
        Lib "SignalProcessing.dll" (dDataInArray As Double, _
                                ByVal lArrayElementCount As Long, _
                                ByRef dRMS As Double) As Boolean
#Else
Declare Function CalcWaveformRMS _
    Lib "SignalProcessing.dll" (dDataInArray As Double, _
                            ByVal lArrayElementCount As Long, _
                            ByRef dRMS As Double) As Boolean
#End If

#If VBA7 Then
    Declare PtrSafe Function bGetBandPkPk _
        Lib "SignalProcessing.dll" (dWaveform As Double, _
                                ByVal lWaveformSamples As Long, _
                                ByVal lBandAnchor As Long, _
                                ByVal lBandSampleCount As Long, _
                                ByVal lBandOffsetSampleCount As Long, _
                                ByRef dBandPkPk As Double) As Boolean
#Else
    Declare Function bGetBandPkPk _
        Lib "SignalProcessing.dll" (dWaveform As Double, _
                                ByVal lWaveformSamples As Long, _
                                ByVal lBandAnchor As Long, _
                                ByVal lBandSampleCount As Long, _
                                ByVal lBandOffsetSampleCount As Long, _
                                ByRef dBandPkPk As Double) As Boolean
#End If

#If VBA7 Then
    Declare PtrSafe Function bGetBandPeakIndex _
        Lib "SignalProcessing.dll" (dWaveform As Double, _
                                ByVal lWaveformSamples As Long, _
                                ByVal lBandAnchor As Long, _
                                ByVal lBandSampleCount As Long, _
                                ByVal lBandOffsetSampleCount As Long, _
                                ByRef lPeakIndex As Long) As Boolean
#Else
    Declare Function bGetBandPeakIndex _
        Lib "SignalProcessing.dll" (dWaveform As Double, _
                                ByVal lWaveformSamples As Long, _
                                ByVal lBandAnchor As Long, _
                                ByVal lBandSampleCount As Long, _
                                ByVal lBandOffsetSampleCount As Long, _
                                ByRef lPeakIndex As Long) As Boolean
#End If

#If VBA7 Then
    Declare PtrSafe Function bGetBandValleyIndex _
        Lib "SignalProcessing.dll" (dWaveform As Double, _
                                ByVal lWaveformSamples As Long, _
                                ByVal lBandAnchor As Long, _
                                ByVal lBandSampleCount As Long, _
                                ByVal lBandOffsetSampleCount As Long, _
                                ByRef lPeakIndex As Long) As Boolean
#Else
    Declare Function bGetBandValleyIndex _
        Lib "SignalProcessing.dll" (dWaveform As Double, _
                                ByVal lWaveformSamples As Long, _
                                ByVal lBandAnchor As Long, _
                                ByVal lBandSampleCount As Long, _
                                ByVal lBandOffsetSampleCount As Long, _
                                ByRef lPeakIndex As Long) As Boolean
#End If

#If VBA7 Then
    Declare PtrSafe Function bGetBandRMS _
        Lib "SignalProcessing.dll" (dWaveform As Double, _
                                ByVal lWaveformSamples As Long, _
                                ByVal lBandAnchor As Long, _
                                ByVal lBandSampleCount As Long, _
                                ByVal lBandOffsetSampleCount As Long, _
                                ByRef dBandRMS As Double) As Boolean
#Else
    Declare Function bGetBandRMS _
        Lib "SignalProcessing.dll" (dWaveform As Double, _
                                ByVal lWaveformSamples As Long, _
                                ByVal lBandAnchor As Long, _
                                ByVal lBandSampleCount As Long, _
                                ByVal lBandOffsetSampleCount As Long, _
                                ByRef dBandRMS As Double) As Boolean
#End If
                            
#If VBA7 Then
    Declare PtrSafe Function bXGetBandAverage _
        Lib "SignalProcessing.dll" (dWaveform As Double, _
                                ByVal lWaveformSamples As Long, _
                                ByVal lBandAnchor As Long, _
                                ByVal lBandSampleCount As Long, _
                                ByVal lBandOffsetSampleCount As Long, _
                                ByRef dAverage As Double) As Boolean
#Else
    Declare Function bXGetBandAverage _
        Lib "SignalProcessing.dll" (dWaveform As Double, _
                                ByVal lWaveformSamples As Long, _
                                ByVal lBandAnchor As Long, _
                                ByVal lBandSampleCount As Long, _
                                ByVal lBandOffsetSampleCount As Long, _
                                ByRef dAverage As Double) As Boolean
#End If
                            
#If VBA7 Then
    Declare PtrSafe Function bXGetWaveformAverage _
        Lib "SignalProcessing.dll" (dWaveform As Double, _
                                ByVal lWaveformSamples As Long, _
                                ByRef dAverage As Double) As Boolean
#Else
    Declare Function bXGetWaveformAverage _
        Lib "SignalProcessing.dll" (dWaveform As Double, _
                                ByVal lWaveformSamples As Long, _
                                ByRef dAverage As Double) As Boolean
#End If
                            
#If VBA7 Then
    Declare PtrSafe Function bXGetWaveformAsACCoupled _
        Lib "SignalProcessing.dll" (dWaveform As Double, _
                                ByVal lWaveformSamples As Long) As Boolean
#Else
    Declare Function bXGetWaveformAsACCoupled _
        Lib "SignalProcessing.dll" (dWaveform As Double, _
                                ByVal lWaveformSamples As Long) As Boolean
#End If
                            
#If VBA7 Then
    Declare PtrSafe Function bXGetColAsDoubleArray _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        dCDFArray As Double, _
                                        ByVal lMaxCDFArrayCount As Long, _
                                        ByVal lCDFColumn As Long, _
                                        ByRef lRowsFound As Long) As Boolean
#Else
    Declare Function bXGetColAsDoubleArray _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        dCDFArray As Double, _
                                        ByVal lMaxCDFArrayCount As Long, _
                                        ByVal lCDFColumn As Long, _
                                        ByRef lRowsFound As Long) As Boolean
#End If
                                    
#If VBA7 Then
    Declare PtrSafe Function bXGetRowAsDoubleArray _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        dCDFArray As Double, _
                                        ByVal lMaxCDFArrayCount As Long, _
                                        ByVal lCDFRow As Long, _
                                        ByRef lColsFound As Long) As Boolean
#Else
    Declare Function bXGetRowAsDoubleArray _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        dCDFArray As Double, _
                                        ByVal lMaxCDFArrayCount As Long, _
                                        ByVal lCDFRow As Long, _
                                        ByRef lColsFound As Long) As Boolean
#End If
                                    
#If VBA7 Then
    Declare PtrSafe Function bXGetRecordAsString _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        ByVal lCDFRow As Long, _
                                        ByVal lCDFColumn As Long, _
                                        ByVal pszRecordString As String, _
                                        ByVal lRecordStringSize As Long) As Boolean
#Else
    Declare Function bXGetRecordAsString _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        ByVal lCDFRow As Long, _
                                        ByVal lCDFColumn As Long, _
                                        ByVal pszRecordString As String, _
                                        ByVal lRecordStringSize As Long) As Boolean
#End If
                                    
#If VBA7 Then
    Declare PtrSafe Function bXGetStringFromArrayAndTime _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        ByVal lStringSize As Long, _
                                        dInputArray As Double, _
                                        ByVal lArrayElementCount As Long, _
                                        ByVal dStartingTime As Double, _
                                        ByVal dEndingTime As Double) As Boolean
#Else
    Declare Function bXGetStringFromArrayAndTime _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        ByVal lStringSize As Long, _
                                        dInputArray As Double, _
                                        ByVal lArrayElementCount As Long, _
                                        ByVal dStartingTime As Double, _
                                        ByVal dEndingTime As Double) As Boolean
#End If
                           
#If VBA7 Then
    Declare PtrSafe Function bXGetStringFromArrays02 _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        ByVal lStringSize As Long, _
                                        dInputArray01 As Double, _
                                        ByVal lArrayElementCount As Long, _
                                        dInputArray02 As Double) As Boolean
#Else
    Declare Function bXGetStringFromArrays02 _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        ByVal lStringSize As Long, _
                                        dInputArray01 As Double, _
                                        ByVal lArrayElementCount As Long, _
                                        dInputArray02 As Double) As Boolean
#End If
                           
#If VBA7 Then
    Declare PtrSafe Function bXGetStringFromArrays03 _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        ByVal lStringSize As Long, _
                                        dInputArray01 As Double, _
                                        ByVal lArrayElementCount As Long, _
                                        dInputArray02 As Double, _
                                        dInputArray03 As Double) As Boolean
#Else
    Declare Function bXGetStringFromArrays03 _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        ByVal lStringSize As Long, _
                                        dInputArray01 As Double, _
                                        ByVal lArrayElementCount As Long, _
                                        dInputArray02 As Double, _
                                        dInputArray03 As Double) As Boolean
#End If
                           
#If VBA7 Then
    Declare PtrSafe Function bXGetStringFromArrays04 _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        ByVal lStringSize As Long, _
                                        dInputArray01 As Double, _
                                        ByVal lArrayElementCount As Long, _
                                        dInputArray02 As Double, _
                                        dInputArray03 As Double, _
                                        dInputArray04 As Double) As Boolean
#Else
    Declare Function bXGetStringFromArrays04 _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        ByVal lStringSize As Long, _
                                        dInputArray01 As Double, _
                                        ByVal lArrayElementCount As Long, _
                                        dInputArray02 As Double, _
                                        dInputArray03 As Double, _
                                        dInputArray04 As Double) As Boolean
#End If
                           
#If VBA7 Then
    Declare PtrSafe Function bXGetStringFromArrays05 _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        ByVal lStringSize As Long, _
                                        dInputArray01 As Double, _
                                        ByVal lArrayElementCount As Long, _
                                        dInputArray02 As Double, _
                                        dInputArray03 As Double, _
                                        dInputArray04 As Double, _
                                        dInputArray05 As Double) As Boolean
#Else
    Declare Function bXGetStringFromArrays05 _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        ByVal lStringSize As Long, _
                                        dInputArray01 As Double, _
                                        ByVal lArrayElementCount As Long, _
                                        dInputArray02 As Double, _
                                        dInputArray03 As Double, _
                                        dInputArray04 As Double, _
                                        dInputArray05 As Double) As Boolean
#End If
                           
#If VBA7 Then
    Declare PtrSafe Function bXGetStringFromArrays06 _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        ByVal lStringSize As Long, _
                                        dInputArray01 As Double, _
                                        ByVal lArrayElementCount As Long, _
                                        dInputArray02 As Double, _
                                        dInputArray03 As Double, _
                                        dInputArray04 As Double, _
                                        dInputArray05 As Double, _
                                        dInputArray06 As Double) As Boolean
#Else
    Declare Function bXGetStringFromArrays06 _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        ByVal lStringSize As Long, _
                                        dInputArray01 As Double, _
                                        ByVal lArrayElementCount As Long, _
                                        dInputArray02 As Double, _
                                        dInputArray03 As Double, _
                                        dInputArray04 As Double, _
                                        dInputArray05 As Double, _
                                        dInputArray06 As Double) As Boolean
#End If
                                    
#If VBA7 Then
    Declare PtrSafe Function bXGetStringFromArrayToRow _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        ByRef lStringSize As Long, _
                                        dInputArray01 As Double, _
                                        ByVal lArrayElementCount As Long) As Boolean
#Else
    Declare Function bXGetStringFromArrayToRow _
        Lib "SignalProcessing.dll" (ByVal pszString As String, _
                                        ByRef lStringSize As Long, _
                                        dInputArray01 As Double, _
                                        ByVal lArrayElementCount As Long)
#End If
                                             
                                    
#If VBA7 Then
    Declare PtrSafe Function bXWaveformResample _
        Lib "SignalProcessing.dll" (dDataInArray As Double, _
                                        ByRef dWaveformTimeLength As Double, _
                                        ByVal lDataInArrayCount As Long, _
                                        dDataOutArray As Double, _
                                        ByVal lDataOutArrayCount As Long) As Boolean
#Else
    Declare Function bXWaveformResample _
        Lib "SignalProcessing.dll" (dDataInArray As Double, _
                                        ByRef dWaveformTimeLength As Double, _
                                        ByVal lDataInArrayCount As Long, _
                                        dDataOutArray As Double, _
                                        ByVal lDataOutArrayCount As Long) As Boolean
#End If

#If VBA7 Then
    Declare PtrSafe Function bGetSlopeIntercept _
        Lib "SignalProcessing.dll" (dIndepArray As Double, _
                                dDepArray As Double, _
                                ByVal lArraySize As Long, _
                                ByRef dSlope As Double, _
                                ByRef dIntercept As Double) As Boolean
#Else
    Declare Function bGetSlopeIntercept _
        Lib "SignalProcessing.dll" (dIndepArray As Double, _
                                dDepArray As Double, _
                                ByVal lArraySize As Long, _
                                ByRef dSlope As Double, _
                                ByRef dIntercept As Double) As Boolean
#End If


Public Function XGetFFTMaxArraySize(lTemp As Integer)

    On Error GoTo ErrorXGetFFTMaxArraySize
    
    'local variables
    Dim sMsg, sErrorLocation As String
    
    XGetFFTMaxArraySize = GetFFTMaxArraySize()
    
    'Avoid Error handler
    Exit Function

ErrorXGetFFTMaxArraySize:
    sErrorLocation = "Error Calling GetFFTMaxArraySize DLL"
    sMsg = sErrorLocation & "->" & Str$(Err.Number) & ": " & Err.Description
    MsgBox sMsg
    Exit Function

End Function

' Revision - 13 Aug 2014
' Added this function to calculate the overshoot ratio

' Given the discharge pressure and maximum pressure, calculate
' the overshoot ratio

Public Function bCalcOvershootRatio(dMaxPressure As Double, _
                                        dDischargePressure As Double, _
                                        ByRef dOvershootRatio As Double)


On Error GoTo Error_bCalcOvershootRatio

    ' Calculate the overshoot ratio
    If (dMaxPressure <> 0) Then
        dOvershootRatio = ((dMaxPressure - dDischargePressure) / dMaxPressure)
    Else
        dOvershootRatio = 0
    End If
        
   ' Success
   bCalcOvershootRatio = True

Exit_bCalcOvershootRatio:
    Exit Function

Error_bCalcOvershootRatio:
    MsgBox "bCalcOvershootRatio - " + Err.Description
    bCalcOvershootRatio = False
    Resume Exit_bCalcOvershootRatio
    
End Function

' Revision - 13 Aug 2014
' Added this function to calculate the undershoot ratio

' Given the discharge pressure and maximum pressure, calculate
' the undershoot ratio

Public Function bCalcUndershootRatio(dMaxPressure As Double, _
                                        dMinPressure As Double, _
                                        dSuctionPressure As Double, _
                                        ByRef dUndershootRatio As Double)


On Error GoTo Error_bCalcUndershootRatio

    ' Calculate the undershoot ratio
    If (dMaxPressure <> 0) Then
        dUndershootRatio = ((dSuctionPressure - dMinPressure) / dMaxPressure)
    Else
        dUndershootRatio = 0
    End If
        
   ' Success
   bCalcUndershootRatio = True

Exit_bCalcUndershootRatio:
    Exit Function

Error_bCalcUndershootRatio:
    MsgBox "bCalcUndershootRatio - " + Err.Description
    bCalcUndershootRatio = False
    Resume Exit_bCalcUndershootRatio
    
End Function


' Used to calculate the kernel half length for smoothing
Public Function bGetHalfKernelLength(lSamplesPerRev As Long, _
                                        ByRef lHalfKernelLength As Long) As Boolean

    lHalfKernelLength = CLng(CDbl(lSamplesPerRev) * 0.01)
    
    bGetHalfKernelLength = True

End Function

' Find the optimal low-pass corner for filtering of gas and combined
' rod load curves
Public Function bGetWaveformLoadFilteredCorner(lWaveformID As Long, _
                                                    lLP_Orders As Long, _
                                                    bCalculateGasLoad As Boolean, _
                                                    bCalculateInertiaLoad As Boolean, _
                                                    Optional bSuppressWarnings As Boolean)
                                                    


    ' Locals
    Dim bTemp As Boolean
    Dim bFilterLoadWaveformLP As Boolean
    Dim bSmoothLoadWaveform As Boolean
    Dim bHighPass As Boolean
    Dim bLowPass As Boolean
    Dim bNotchPass As Boolean
    Dim bBandPass As Boolean
    Dim bIsZeroPhase As Boolean
    
    Dim lMaxReversals As Long
    Dim lIndex As Long
    Dim lSamplesPerRev As Long
    Dim lTemp As Long
    Dim lSampleCount As Long
    Dim lPoleCount As Long
    
    Dim dMinimumSeparatation_Degrees As Double
    Dim dReversalSeparation As Double
    Dim dReversalArrayBaseline(8) As Double
    Dim dReversalArrayTest(8) As Double
    Dim dLoad_USCS(131070) As Double
    Dim dLoadSmoothed_USCS(131070) As Double
    Dim dRPM As Double
    Dim dSamplingFrequency As Double
    Dim dHP As Double
    Dim dLP As Double
    Dim dPercentRipple As Double

    ' Initialization
    lMaxReversals = 8
    dMinimumSeparatation_Degrees = 15#
    bSmoothLoadWaveform = False
    bSuppressWarnings = True
    
    ' Retrieve the RPM
    bTemp = bGetWaveformRPM(lWaveformID, dRPM)
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformLoadFilteredCorner
    End If
    
    ' Calculate the load waveform
    bTemp = bGetLoadWaveform_USCS(lWaveformID, _
                                            dLoad_USCS(), _
                                            bCalculateGasLoad, _
                                            bCalculateInertiaLoad, _
                                            lSamplesPerRev, _
                                            lSampleCount, _
                                            bSuppressWarnings)
    If (bTemp = False) Then
        If (bSuppressWarnings = False) Then
            MsgBox "Invalid lSamplesPerRev in bGetWaveformLoadFilteredCorner"
        End If
        bGetWaveformLoadFilteredCorner = False
        GoTo Exit_bGetWaveformLoadFilteredCorner
    End If
                                            
    ' Establish filter parameters and take the first pass.  This
    ' should result in a grossly distorted waveform that increases
    ' in the low-pass filter improve.
    lLP_Orders = 3
    bHighPass = False
    bLowPass = True
    bNotchPass = False
    bBandPass = False
    bIsZeroPhase = True
    dSamplingFrequency = ((dRPM / 60#) * CDbl(lSamplesPerRev))
    dHP = (CDbl(lLP_Orders) * (dRPM / 60#))
    dLP = dHP
    dPercentRipple = 0.5
    lPoleCount = 4
    lTemp = FilterWaveform(dLoad_USCS(0), _
                dLoadSmoothed_USCS(0), _
                lSamplesPerRev, _
                bHighPass, _
                bLowPass, _
                bNotchPass, _
                bBandPass, _
                bIsZeroPhase, _
                dHP, _
                dLP, _
                dSamplingFrequency, _
                dPercentRipple, _
                lPoleCount)
    
    If (lTemp < 0) Then
        GoTo Exit_bGetWaveformLoadFilteredCorner
    End If
    
    ' Calculate the initial reversal points
    bTemp = bGetReversalArrayFromLoad(dLoad_USCS(), _
                                        lSamplesPerRev, _
                                        dReversalArrayBaseline(), _
                                        lMaxReversals, _
                                        dMinimumSeparatation_Degrees)
                                            
    
    ' Begin optimization loop
    dReversalSeparation = 100#
    lLP_Orders = (lLP_Orders + 1)
    While (dReversalSeparation > 0.5 And lLP_Orders < 21)
    
        ' Reset the sum variable
        dReversalSeparation = 0#
        
        ' Calculate filter corners.
        dHP = (CDbl(lLP_Orders) * (dRPM / 60#))
        dLP = dHP
        lTemp = FilterWaveform(dLoad_USCS(0), _
                    dLoadSmoothed_USCS(0), _
                    lSamplesPerRev, _
                    bHighPass, _
                    bLowPass, _
                    bNotchPass, _
                    bBandPass, _
                    bIsZeroPhase, _
                    dHP, _
                    dLP, _
                    dSamplingFrequency, _
                    dPercentRipple, _
                    lPoleCount)
    
        ' Did the filter work?
        If (lTemp < 0) Then
            MsgBox "FilterWaveform Failed in bGetWaveformLoadFilteredCorner"
        End If
    
        ' Calculate the new reversal points
        bTemp = bGetReversalArrayFromLoad(dLoadSmoothed_USCS(), _
                                            lSamplesPerRev, _
                                            dReversalArrayTest(), _
                                            lMaxReversals, _
                                            dMinimumSeparatation_Degrees)
                                            
        ' Calculate the difference between reversals and copy new reversal
        ' array over the old baseline.
        For lIndex = 0 To (lMaxReversals - 1)
        
            dReversalSeparation = dReversalSeparation + Abs(dReversalArrayBaseline(lIndex) - dReversalArrayTest(lIndex))
            dReversalArrayBaseline(lIndex) = dReversalArrayTest(lIndex)
        
        Next lIndex

        'Increment the filter corner
        lLP_Orders = lLP_Orders + 1
        
    Wend

    ' Success
    bGetWaveformLoadFilteredCorner = True

Exit_bGetWaveformLoadFilteredCorner:
    Exit Function

Error_bGetWaveformLoadFilteredCorner:
    MsgBox "bGetDischargePressure_USCS - " + Err.Description
    Resume Exit_bGetWaveformLoadFilteredCorner
    
End Function


' Wrapper for the correlation coefficient
Public Function bGetCorrelationCoeff_ByWaveformID(lWaveformID As Long, _
                                        ByRef dCorrelationCoeff As Double) As Boolean
                                        
On Error GoTo Error_bGetCorrelationCoeff_ByWaveformID
                                        
    'Local variables
    Dim x As String
    Dim Text0 As String
    Dim sCaption As String
    Dim sTemp As String
    Dim dWaveform1(131072) As Double
    Dim dWaveform2(65535) As Double
    Dim bTemp As Boolean
    Dim bReturnAllSamples As Boolean
    Dim lWaveformSampleCount As Long
    Dim lSamplesPerRev As Long
    Dim lIndex As Long
     
    ' Retrieve the waveform
    bReturnAllSamples = True
    bTemp = bGetWaveform_USCS(lWaveformID, dWaveform1(), bReturnAllSamples)
    If (bTemp = False) Then
        GoTo Exit_bGetCorrelationCoeff_ByWaveformID
    End If
    
    ' Retrieve the waveform samplecount
    bTemp = bGetWaveformSampleCount(lWaveformID, lWaveformSampleCount)
    If (bTemp = False) Then
        GoTo Exit_bGetCorrelationCoeff_ByWaveformID
    End If
    
    'Retrieve the samples per rev
    bTemp = bGetWaveformSamplesPerRev(lWaveformID, lSamplesPerRev)
    If (bTemp = False) Then
        GoTo Exit_bGetCorrelationCoeff_ByWaveformID
    End If
    
    ' See if this waveform has two or more revolutions
    If (lSamplesPerRev >= lWaveformSampleCount) Then
        dCorrelationCoeff = 0#
        GoTo Exit_bGetCorrelationCoeff_ByWaveformID
    End If
    
    ' Calculations are simpler with AC-Coupled waveforms
    'bTemp = bXGetWaveformAsACCoupled(dWaveform1(0), _
    '                    lWaveformSampleCount)
    'If (bTemp = False) Then
    '    GoTo Exit_bGetCorrelationCoeff_ByWaveformID
    'End If

    ' Copy the second half of the waveform into the second array
    For lIndex = 0 To (lWaveformSampleCount / 2)
    
        dWaveform2(lIndex) = dWaveform1((lWaveformSampleCount / 2) + lIndex)
    
    Next lIndex

    ' Calculate the coefficient
    dCorrelationCoeff = 0#
    bTemp = bGetCorrelationCoeff(dWaveform1(), _
                                        dWaveform2(), _
                                        (lWaveformSampleCount / 2), _
                                        dCorrelationCoeff)
                                        
Exit_bGetCorrelationCoeff_ByWaveformID:
    bGetCorrelationCoeff_ByWaveformID = True
    Exit Function

Error_bGetCorrelationCoeff_ByWaveformID:
    MsgBox "Error_bGetCorrelationCoeff_ByWaveformID - " + Err.Description
    Resume Exit_bGetCorrelationCoeff_ByWaveformID
    
End Function

' Get the chamber loaded coefficient, given a cylinder serial number
Public Function bGetChamberLoadedCoeff(sCylinderSerialNo As String, _
                                            ByRef dChamberLoadedCoeff As Double) As Boolean
                                                
On Error GoTo Error_bGetChamberLoadedCoeff

    'Local Variables
    Dim strSQL As String
    Dim bTemp As Boolean
    Dim dbsMachineNameplate As Database
    Dim qdfMachineNameplate As QueryDef
    Dim rstMachineNameplate As Recordset
    
    'Initialize variables
    Set dbsMachineNameplate = CurrentDb
   
    ' Query to retrieve the nameplate record
    strSQL = "SELECT [Machine Nameplate].[Serial Number],[Machine Nameplate].[ChamberLoadedCoeff] From [Machine Nameplate] WHERE( [Machine Nameplate].[Serial Number] = '" & sCylinderSerialNo & "' ) "
    Set qdfMachineNameplate = dbsMachineNameplate.CreateQueryDef("", strSQL)
    Set rstMachineNameplate = qdfMachineNameplate.OpenRecordset()
            
    'Should be one record here
    If (rstMachineNameplate.RecordCount <= 0) Then
        bGetChamberLoadedCoeff = False
        GoTo Exit_bGetChamberLoadedCoeff
    Else
        If (IsNull(rstMachineNameplate("ChamberLoadedCoeff"))) Then
            MsgBox "No ChamberLoadedCoeff found for cylinder serial number " & sCylinderSerialNo
        Else
            dChamberLoadedCoeff = rstMachineNameplate("ChamberLoadedCoeff")
        End If
    End If
    
    'success
    bGetChamberLoadedCoeff = True
    
Exit_bGetChamberLoadedCoeff:
    Exit Function

Error_bGetChamberLoadedCoeff:
    MsgBox "bGetChamberLoadedCoeff - " + Err.Description
    Resume Exit_bGetChamberLoadedCoeff
    
End Function

' Added this to supprt the different coefficients for each end
' 19 Mar 2016
' Get the chamber loaded coefficient, given a cylinder serial number
Public Function bGetChamberLoadedCoeffCE(sCylinderSerialNo As String, _
                                            ByRef dChamberLoadedCoeffCE As Double) As Boolean
                                                
On Error GoTo Error_bGetChamberLoadedCoeffCE

    'Local Variables
    Dim strSQL As String
    Dim bTemp As Boolean
    Dim dbsMachineNameplate As Database
    Dim qdfMachineNameplate As QueryDef
    Dim rstMachineNameplate As Recordset
    
    'Initialize variables
    Set dbsMachineNameplate = CurrentDb
   
    ' Query to retrieve the nameplate record
    strSQL = "SELECT [Machine Nameplate].[Serial Number],[Machine Nameplate].[ChamberLoadedCoeffCE] From [Machine Nameplate] WHERE( [Machine Nameplate].[Serial Number] = '" & sCylinderSerialNo & "' ) "
    Set qdfMachineNameplate = dbsMachineNameplate.CreateQueryDef("", strSQL)
    Set rstMachineNameplate = qdfMachineNameplate.OpenRecordset()
            
    'Should be one record here
    If (rstMachineNameplate.RecordCount <= 0) Then
        bGetChamberLoadedCoeffCE = False
        GoTo Exit_bGetChamberLoadedCoeffCE
    Else
        If (IsNull(rstMachineNameplate("ChamberLoadedCoeffCE"))) Then
            MsgBox "No ChamberLoadedCoeffCE found for cylinder serial number " & sCylinderSerialNo
        Else
            dChamberLoadedCoeffCE = rstMachineNameplate("ChamberLoadedCoeffCE")
        End If
    End If
    
    'success
    bGetChamberLoadedCoeffCE = True
    
Exit_bGetChamberLoadedCoeffCE:
    Exit Function

Error_bGetChamberLoadedCoeffCE:
    MsgBox "bGetChamberLoadedCoeffCE - " + Err.Description
    Resume Exit_bGetChamberLoadedCoeffCE
    
End Function


' Added this to supprt the different coefficients for each end
' 19 Mar 2016
' Get the chamber loaded coefficient, given a cylinder serial number
Public Function bGetChamberLoadedCoeffHE(sCylinderSerialNo As String, _
                                            ByRef dChamberLoadedCoeffHE As Double) As Boolean
                                                
On Error GoTo Error_bGetChamberLoadedCoeffHE

    'Local Variables
    Dim strSQL As String
    Dim bTemp As Boolean
    Dim dbsMachineNameplate As Database
    Dim qdfMachineNameplate As QueryDef
    Dim rstMachineNameplate As Recordset
    
    'Initialize variables
    Set dbsMachineNameplate = CurrentDb
   
    ' Query to retrieve the nameplate record
    strSQL = "SELECT [Machine Nameplate].[Serial Number],[Machine Nameplate].[ChamberLoadedCoeffHE] From [Machine Nameplate] WHERE( [Machine Nameplate].[Serial Number] = '" & sCylinderSerialNo & "' ) "
    Set qdfMachineNameplate = dbsMachineNameplate.CreateQueryDef("", strSQL)
    Set rstMachineNameplate = qdfMachineNameplate.OpenRecordset()
            
    'Should be one record here
    If (rstMachineNameplate.RecordCount <= 0) Then
        bGetChamberLoadedCoeffHE = False
        GoTo Exit_bGetChamberLoadedCoeffHE
    Else
        If (IsNull(rstMachineNameplate("ChamberLoadedCoeffHE"))) Then
            MsgBox "No ChamberLoadedCoeffHE found for cylinder serial number " & sCylinderSerialNo
        Else
            dChamberLoadedCoeffHE = rstMachineNameplate("ChamberLoadedCoeffHE")
        End If
    End If
    
    'success
    bGetChamberLoadedCoeffHE = True
    
Exit_bGetChamberLoadedCoeffHE:
    Exit Function

Error_bGetChamberLoadedCoeffHE:
    MsgBox "bGetChamberLoadedCoeffHE - " + Err.Description
    Resume Exit_bGetChamberLoadedCoeffHE
    
End Function


' This function calculates the correlation coefficient for two waveforms
' See algorithm below and
' http://stackoverflow.com/questions/1289415/what-is-a-good-r-value-when-comparing-2-signals-using-cross-correlation
' for more details.
Public Function bGetCorrelationCoeff(dWaveform1() As Double, _
                                        dWaveform2() As Double, _
                                        lWaveformCount As Double, _
                                        ByRef dCorrelationCoeff As Double) As Boolean


On Error GoTo Error_bGetCorrelationCoeff

    ' Locals
    Dim lIndex As Long
    Dim dSumSx As Double
    Dim dSumSxx As Double
    Dim dSumSy As Double
    Dim dSumSyy As Double
    Dim dSumSxy As Double
    Dim dSxx As Double
    Dim dSyy As Double
    Dim dSxy As Double
    
    ' This is the loop to calculate the squares
    dSumSx = 0
    dSumSxx = 0
    dSumSy = 0
    dSumSyy = 0
    dSumSxy = 0
    For lIndex = 0 To (lWaveformCount - 1)
            
        dSumSx = dSumSx + dWaveform1(lIndex)
        dSumSxx = dSumSxx + (dWaveform1(lIndex) * dWaveform1(lIndex))
        dSumSy = dSumSy + dWaveform2(lIndex)
        dSumSyy = dSumSyy + (dWaveform2(lIndex) * dWaveform2(lIndex))
        dSumSxy = dSumSxy + (dWaveform1(lIndex) * dWaveform2(lIndex))
        
    Next lIndex

    ' Calculate correlation coefficient
    dSxx = dSumSxx - ((dSumSx * dSumSx) / lWaveformCount)
    dSyy = dSumSyy - ((dSumSy * dSumSy) / lWaveformCount)
    dSxy = dSumSxy - ((dSumSx * dSumSy) / lWaveformCount)
    dCorrelationCoeff = dSxy / Sqr(dSxx * dSyy)
    
Exit_bGetCorrelationCoeff:
    bGetCorrelationCoeff = True
    Exit Function

Error_bGetCorrelationCoeff:
    MsgBox "Error_bGetCorrelationCoeff - " + Err.Description
    Resume Exit_bGetCorrelationCoeff

End Function
' Discharge pressure in the native units of the waveform
Public Function bGetDischargePressure(lWaveformID As Long, _
                                        ByRef dPressure As Double, _
                                        Optional bSuppressErrorMessages As Boolean, _
                                        Optional bFilterWaveform As Boolean) As Boolean

On Error GoTo Error_bGetDischargePressure
            
    'Local variables
    Dim bTemp As Boolean
    Dim bConvertToUSCS As Boolean
    Dim bConvertToMetric As Boolean
    Dim bEntireWaveform As Boolean
    Dim lSamplesPerRev As Long
    Dim bHeadEndChamber As Boolean
    Dim dPressureGage(131070) As Double
    
    'Retrieve the waveform in U.S. customary units
    'Error handling at the ModuleDatabaseInterface level
    bConvertToUSCS = True
    bConvertToMetric = False
    bEntireWaveform = False
    If bFilterWaveform = False Then
    
        bTemp = bGetWaveform(lWaveformID, _
                                        dPressureGage(), _
                                        bConvertToUSCS, _
                                        bConvertToMetric, _
                                        bEntireWaveform)
                                        
        
    Else
        
        bTemp = bGetWaveformFilteredByRecord(lWaveformID, _
                                                    dPressureGage(), _
                                                    bConvertToUSCS, _
                                                    bConvertToMetric, _
                                                    bEntireWaveform, _
                                                    bSuppressErrorMessages)
    
    
    End If
    
    If (bTemp = False) Then
        bGetDischargePressure = False
        GoTo Exit_bGetDischargePressure
    End If
    
    'See if this is the crank end or head end
    bTemp = bGetWaveformChamber(lWaveformID, _
                                    bHeadEndChamber, _
                                    bSuppressErrorMessages)
    If (bTemp = False) Then
        bGetDischargePressure = False
        GoTo Exit_bGetDischargePressure
    End If
    
    'Retrieve the number of samples...error handling
    'at the ModuleDatabaseInterface level
    bTemp = bGetWaveformSamplesPerRev(lWaveformID, lSamplesPerRev)
    If (bTemp = False) Then
        bGetDischargePressure = False
        GoTo Exit_bGetDischargePressure
    End If
    
    'Update the value
    If (bHeadEndChamber = False) Then
        dPressure = dPressureGage(lSamplesPerRev / 2)
    Else
        dPressure = dPressureGage(0)
    End If

    bGetDischargePressure = True

Exit_bGetDischargePressure:
    Exit Function

Error_bGetDischargePressure:
    MsgBox "bGetDischargePressure - " + Err.Description
    Resume Exit_bGetDischargePressure
    
End Function

' Discharge pressure in USCS unit
Public Function bGetDischargePressure_USCS(lWaveformID As Long, _
                                        ByRef dPressure As Double, _
                                        Optional bSuppressErrorMessages As Boolean, _
                                        Optional bFilterWaveform As Boolean) As Boolean

On Error GoTo Error_bGetDischargePressure_USCS
            
    'Local variables
    Dim bTemp As Boolean
    Dim bConvertToUSCS As Boolean
    Dim bConvertToMetric As Boolean
    Dim bEntireWaveform As Boolean
    Dim lSamplesPerRev As Long
    Dim bHeadEndChamber As Boolean
    Dim dPressureGage(131070) As Double
    
    'Retrieve the waveform in U.S. customary units
    'Error handling at the ModuleDatabaseInterface level
    If bFilterWaveform = False Then
    
        bTemp = bGetWaveform_USCS(lWaveformID, dPressureGage())
        
    Else
        
        bConvertToUSCS = True
        bConvertToMetric = False
        bEntireWaveform = False
        bTemp = bGetWaveformFilteredByRecord(lWaveformID, _
                                                    dPressureGage(), _
                                                    bConvertToUSCS, _
                                                    bConvertToMetric, _
                                                    bEntireWaveform, _
                                                    bSuppressErrorMessages)
    
    
    End If
    
    If (bTemp = False) Then
        bGetDischargePressure_USCS = False
        GoTo Exit_bGetDischargePressure_USCS
    End If
    
    'See if this is the crank end or head end
    bTemp = bGetWaveformChamber(lWaveformID, _
                                    bHeadEndChamber, _
                                    bSuppressErrorMessages)
    If (bTemp = False) Then
        bGetDischargePressure_USCS = False
        GoTo Exit_bGetDischargePressure_USCS
    End If
    
    'Retrieve the number of samples...error handling
    'at the ModuleDatabaseInterface level
    bTemp = bGetWaveformSamplesPerRev(lWaveformID, lSamplesPerRev)
    If (bTemp = False) Then
        bGetDischargePressure_USCS = False
        GoTo Exit_bGetDischargePressure_USCS
    End If
    
    'Update the value
    If (bHeadEndChamber = False) Then
        dPressure = dPressureGage(lSamplesPerRev / 2)
    Else
        dPressure = dPressureGage(0)
    End If

    bGetDischargePressure_USCS = True

Exit_bGetDischargePressure_USCS:
    Exit Function

Error_bGetDischargePressure_USCS:
    MsgBox "bGetDischargePressure_USCS - " + Err.Description
    Resume Exit_bGetDischargePressure_USCS
    
End Function

Public Function bGetDischargePressureAbsolute_USCS(lWaveformID As Long, _
                                        ByRef dPressureDischargeAbsolute_USCS As Double) As Boolean

On Error GoTo Error_bGetDischargePressureAbsolute
            
    'Local variables
    Dim bTemp As Boolean
    Dim lSamplesPerRev As Long
    Dim lWaveformDescriptionID As Long
    Dim lWaveformUnitsID As Long
    Dim dPressure(131070) As Double
    Dim dAmbientPressure_USCS As Double
    
    'Retrieve the waveform in U.S. customary units
    'Error handling at the ModuleDatabaseInterface level
    bTemp = bGetWaveform_USCS(lWaveformID, dPressure())
    If (bTemp = False) Then
        bGetDischargePressureAbsolute_USCS = False
        GoTo Exit_bGetDischargePressureAbsolute
    End If
    
    'See if this is the crank end or head end
    bTemp = bGetWaveformDescriptionID(lWaveformID, lWaveformDescriptionID)
    If (bTemp = False) Then
        bGetDischargePressureAbsolute_USCS = False
        GoTo Exit_bGetDischargePressureAbsolute
    End If
    
    'Retrieve the number of samples...error handling
    'at the ModuleDatabaseInterface level
    bTemp = bGetWaveformSamplesPerRev(lWaveformID, lSamplesPerRev)
    If (bTemp = False) Then
        bGetDischargePressureAbsolute_USCS = False
        GoTo Exit_bGetDischargePressureAbsolute
    End If
    
    'Update the value, waveform description ID = 1 is the
    'crank end
    If (lWaveformDescriptionID = 1) Then
        dPressureDischargeAbsolute_USCS = dPressure(lSamplesPerRev / 2)
    Else
        dPressureDischargeAbsolute_USCS = dPressure(0)
    End If
    
    'If this is a gage pressure curve then add the barometric
    'pressure to get absolute
    bTemp = bGetWaveformUnitsID(lWaveformID, _
                                    lWaveformUnitsID)
    If (bTemp = False) Then
        bGetDischargePressureAbsolute_USCS = False
        GoTo Exit_bGetDischargePressureAbsolute
    End If
    
    If (lWaveformUnitsID = 3 Or lWaveformUnitsID = 11) Then
    
        bTemp = bGetProcessAmbientPressureByWaveformID_USCS(lWaveformID, _
                                    dAmbientPressure_USCS)

        If (bTemp = False) Then
            bGetDischargePressureAbsolute_USCS = False
            GoTo Exit_bGetDischargePressureAbsolute
        End If
    
        dPressureDischargeAbsolute_USCS = (dPressureDischargeAbsolute_USCS + dAmbientPressure_USCS)
    
    End If
        
    bGetDischargePressureAbsolute_USCS = True

Exit_bGetDischargePressureAbsolute:
    Exit Function

Error_bGetDischargePressureAbsolute:
    MsgBox "bGetDischargePressureAbsolute_USCS - " + Err.Description
    Resume Exit_bGetDischargePressureAbsolute
    
End Function

Public Function bGetDischargeValveOpenIndex(lWaveformID As Long, _
                                        ByRef lDischargeValveOpenIndex As Long) As Boolean

On Error GoTo Error_bGetDischargeValveOpenIndex
            
    'Local variables
    Dim bTemp As Boolean
    Dim bCrossingFlag As Boolean
    Dim i As Long
    Dim lWaveformDescriptionID As Long
    Dim lSamplesPerRev As Long
    Dim dPressureGage(131070) As Double
    Dim dDischargePressure As Double
    
    'Retrieve the discharge pressure
    bTemp = bGetDischargePressure_USCS(lWaveformID, dDischargePressure)
    If (bTemp = False) Then
        bGetDischargeValveOpenIndex = False
        GoTo Exit_bGetDischargeValveOpenIndex
    End If
        
     'Retrieve the cylinder pressure waveform
    bTemp = bGetWaveform_USCS(lWaveformID, dPressureGage())
    If (bTemp = False) Then
        bGetDischargeValveOpenIndex = False
        GoTo Exit_bGetDischargeValveOpenIndex
    End If
    
    'See if this is the crank end or head end
    bTemp = bGetWaveformDescriptionID(lWaveformID, lWaveformDescriptionID)
    If (bTemp = False) Then
        bGetDischargeValveOpenIndex = False
        GoTo Exit_bGetDischargeValveOpenIndex
    End If
    
    'Retrieve the number of samples...error handling
    'at the ModuleDatabaseInterface level
    bTemp = bGetWaveformSamplesPerRev(lWaveformID, lSamplesPerRev)
    If (bTemp = False) Then
        bGetDischargeValveOpenIndex = False
        GoTo Exit_bGetDischargeValveOpenIndex
    End If
    
    'Search through the array for pressure crossing
    If (lWaveformDescriptionID = 1) Then
        i = 0
    Else
        i = (lSamplesPerRev / 2)
    End If
    
    bCrossingFlag = False
    
    While (i < lSamplesPerRev)
        
        If ((bCrossingFlag = False) And dPressureGage(i) >= dDischargePressure) Then
            bCrossingFlag = True
            lDischargeValveOpenIndex = i
        End If
        
        i = i + 1
        
    Wend
    
   
    'Update the value for the function
    bGetDischargeValveOpenIndex = bCrossingFlag

Exit_bGetDischargeValveOpenIndex:
    Exit Function

Error_bGetDischargeValveOpenIndex:
    MsgBox "bGetDischargeValveOpenIndex - " + Err.Description
    Resume Exit_bGetDischargeValveOpenIndex
    
End Function

' Retrieve the suction pressure in native waveform units
Public Function bGetSuctionPressure(lWaveformID As Long, _
                                        ByRef dPressure As Double, _
                                        Optional bSuppressErrorMessages As Boolean, _
                                        Optional bFilterWaveform As Boolean) As Boolean

On Error GoTo Error_bGetSuctionPressure
            
    'Local variables
    Dim bTemp As Boolean
    Dim bHeadEndChamber As Boolean
    Dim bConvertToMetric As Boolean
    Dim bConvertToUSCS As Boolean
    Dim bEntireWaveform As Boolean
    Dim lSamplesPerRev As Long
    Dim dPressureGage(131070) As Double
    
    'Retrieve the waveform, ignore units
    'Error handling at the ModuleDatabaseInterface level
    bConvertToUSCS = False
    bConvertToMetric = False
    bEntireWaveform = False
    
    If bFilterWaveform = False Then
    
        bTemp = bGetWaveform(lWaveformID, _
                                        dPressureGage(), _
                                        bConvertToUSCS, _
                                        bConvertToMetric, _
                                        bEntireWaveform)
                                        
    Else
        
        bTemp = bGetWaveformFilteredByRecord(lWaveformID, _
                                                    dPressureGage(), _
                                                    bConvertToUSCS, _
                                                    bConvertToMetric, _
                                                    bEntireWaveform, _
                                                    bSuppressErrorMessages)
    End If
    
    If (bTemp = False) Then
        bGetSuctionPressure = False
        GoTo Exit_bGetSuctionPressure
    End If
    
    'See if this is the crank end or head end
    bTemp = bGetWaveformChamber(lWaveformID, _
                                    bHeadEndChamber, _
                                    bSuppressErrorMessages)
    If (bTemp = False) Then
        bGetSuctionPressure = False
        GoTo Exit_bGetSuctionPressure
    End If
    
    'Retrieve the number of samples...error handling
    'at the ModuleDatabaseInterface level
    bTemp = bGetWaveformSamplesPerRev(lWaveformID, lSamplesPerRev)
    If (bTemp = False) Then
        bGetSuctionPressure = False
        GoTo Exit_bGetSuctionPressure
    End If
    
    ' Update the value
    If (bHeadEndChamber = False) Then
        dPressure = dPressureGage(0)
    Else
        dPressure = dPressureGage(lSamplesPerRev / 2#)
    End If
    
    'success
    bGetSuctionPressure = True

Exit_bGetSuctionPressure:
    Exit Function

Error_bGetSuctionPressure:
    MsgBox "bGetSuctionPressure - " + Err.Description
    Resume Exit_bGetSuctionPressure
    
End Function

' Retrieve the suction pressure in USCS units
Public Function bGetSuctionPressure_USCS(lWaveformID As Long, _
                                        ByRef dPressure As Double, _
                                        Optional bSuppressErrorMessages As Boolean, _
                                        Optional bFilterWaveform As Boolean) As Boolean

On Error GoTo Error_bGetSuctionPressure_USCS
            
    'Local variables
    Dim bTemp As Boolean
    Dim bHeadEndChamber As Boolean
    Dim bConvertToMetric As Boolean
    Dim bConvertToUSCS As Boolean
    Dim bEntireWaveform As Boolean
    Dim lSamplesPerRev As Long
    Dim dPressureGage(131070) As Double
    
    'Retrieve the waveform in U.S. customary units
    'Error handling at the ModuleDatabaseInterface level
    If bFilterWaveform = False Then
    
        bTemp = bGetWaveform_USCS(lWaveformID, dPressureGage())
    
    Else
        
        bConvertToUSCS = True
        bConvertToMetric = False
        bEntireWaveform = False
        bTemp = bGetWaveformFilteredByRecord(lWaveformID, _
                                                    dPressureGage(), _
                                                    bConvertToUSCS, _
                                                    bConvertToMetric, _
                                                    bEntireWaveform, _
                                                    bSuppressErrorMessages)
    End If
    
    If (bTemp = False) Then
        bGetSuctionPressure_USCS = False
        GoTo Exit_bGetSuctionPressure_USCS
    End If
    
    'See if this is the crank end or head end
    bTemp = bGetWaveformChamber(lWaveformID, _
                                    bHeadEndChamber, _
                                    bSuppressErrorMessages)
    If (bTemp = False) Then
        bGetSuctionPressure_USCS = False
        GoTo Exit_bGetSuctionPressure_USCS
    End If
    
    'Retrieve the number of samples...error handling
    'at the ModuleDatabaseInterface level
    bTemp = bGetWaveformSamplesPerRev(lWaveformID, lSamplesPerRev)
    If (bTemp = False) Then
        bGetSuctionPressure_USCS = False
        GoTo Exit_bGetSuctionPressure_USCS
    End If
    
    ' Update the value
    If (bHeadEndChamber = False) Then
        dPressure = dPressureGage(0)
    Else
        dPressure = dPressureGage(lSamplesPerRev / 2#)
    End If
    
    'success
    bGetSuctionPressure_USCS = True

Exit_bGetSuctionPressure_USCS:
    Exit Function

Error_bGetSuctionPressure_USCS:
    MsgBox "bGetSuctionPressure_USCS - " + Err.Description
    Resume Exit_bGetSuctionPressure_USCS
    
End Function

Public Function bGetSuctionPressureAbsolute_USCS(lWaveformID As Long, _
                                        ByRef dPressureSuctionAbsolute_USCS As Double) As Boolean

On Error GoTo Error_bGetSuctionPressureAbsolute
            
    'Local variables
    Dim bTemp As Boolean
    Dim lSamplesPerRev As Long
    Dim lWaveformDescriptionID As Long
    Dim lWaveformUnitsID As Long
    Dim dPressure(131070) As Double
    Dim dAmbientPressure_USCS As Double
    
    'Retrieve the waveform in U.S. customary units
    'Error handling at the ModuleDatabaseInterface level
    bTemp = bGetWaveform_USCS(lWaveformID, dPressure())
    If (bTemp = False) Then
        bGetSuctionPressureAbsolute_USCS = False
        GoTo Exit_bGetSuctionPressureAbsolute
    End If
    
    'See if this is the crank end or head end
    bTemp = bGetWaveformDescriptionID(lWaveformID, lWaveformDescriptionID)
    If (bTemp = False) Then
        bGetSuctionPressureAbsolute_USCS = False
        GoTo Exit_bGetSuctionPressureAbsolute
    End If
    
    'Retrieve the number of samples...error handling
    'at the ModuleDatabaseInterface level
    bTemp = bGetWaveformSamplesPerRev(lWaveformID, lSamplesPerRev)
    If (bTemp = False) Then
        bGetSuctionPressureAbsolute_USCS = False
        GoTo Exit_bGetSuctionPressureAbsolute
    End If
    
    'Update the value, waveform description ID = 1 is the
    'crank end
    If (lWaveformDescriptionID = 1) Then
        dPressureSuctionAbsolute_USCS = dPressure(0)
    Else
        dPressureSuctionAbsolute_USCS = dPressure(lSamplesPerRev / 2)
    End If
    
    'If this is a gage pressure curve then add the barometric
    'pressure to get absolute
    bTemp = bGetWaveformUnitsID(lWaveformID, _
                                    lWaveformUnitsID)
    If (bTemp = False) Then
        bGetSuctionPressureAbsolute_USCS = False
        GoTo Exit_bGetSuctionPressureAbsolute
    End If
    
    If (lWaveformUnitsID = 3 Or lWaveformUnitsID = 11) Then
    
        bTemp = bGetProcessAmbientPressureByWaveformID_USCS(lWaveformID, _
                                            dAmbientPressure_USCS)
        If (bTemp = False) Then
            bGetSuctionPressureAbsolute_USCS = False
            GoTo Exit_bGetSuctionPressureAbsolute
        End If
    
        dPressureSuctionAbsolute_USCS = (dPressureSuctionAbsolute_USCS + dAmbientPressure_USCS)
    
    End If
        
    bGetSuctionPressureAbsolute_USCS = True

Exit_bGetSuctionPressureAbsolute:
    Exit Function

Error_bGetSuctionPressureAbsolute:
    MsgBox "bGetSuctionPressureAbsolute_USCS - " + Err.Description
    Resume Exit_bGetSuctionPressureAbsolute
    
End Function

'This method returns the crank angle at which the suction valve opened
Public Function bGetSuctionValveOpenIndex(lWaveformID As Long, _
                                        ByRef lSuctionValveOpenIndex As Long) As Boolean

On Error GoTo Error_bGetSuctionValveOpenIndex
            
    'Local variables
    Dim bTemp As Boolean
    Dim bCrossingFlag As Boolean
    Dim i As Long
    Dim lColsFound As Long
    Dim lWaveformDescriptionID As Long
    Dim lSamplesPerRev As Long
    Dim dPressureGage(131070) As Double
    Dim dSuctionPressure As Double
    
    'Retrieve the suction pressure
    bTemp = bGetSuctionPressure_USCS(lWaveformID, dSuctionPressure)
    If (bTemp = False) Then
        bGetSuctionValveOpenIndex = False
        GoTo Exit_bGetSuctionValveOpenIndex
    End If
        
    'Retrieve the cylinder pressure waveform
    bTemp = bGetWaveform_USCS(lWaveformID, dPressureGage())
    If (bTemp = False) Then
        bGetSuctionValveOpenIndex = False
        GoTo Exit_bGetSuctionValveOpenIndex
    End If
    
    'See if this is the crank end or head end
    bTemp = bGetWaveformDescriptionID(lWaveformID, lWaveformDescriptionID)
    If (bTemp = False) Then
        bGetSuctionValveOpenIndex = False
        GoTo Exit_bGetSuctionValveOpenIndex
    End If
    
    'Retrieve the number of samples...error handling
    'at the ModuleDatabaseInterface level
    bTemp = bGetWaveformSamplesPerRev(lWaveformID, lSamplesPerRev)
    If (bTemp = False) Then
        bGetSuctionValveOpenIndex = False
        GoTo Exit_bGetSuctionValveOpenIndex
    End If
    
    'Search through the array for first time the pressure
    'value drops below the suction pressure.  For the crank
    'end chamber, start at bottom dead center (BDC).
    If (lWaveformDescriptionID = 1) Then
        i = (lSamplesPerRev / 2)
    Else
        i = 0
    End If
    
    bCrossingFlag = False
    
    While (i < lSamplesPerRev)
        
        If (Not (bCrossingFlag) And dPressureGage(i) < dSuctionPressure) Then
            bCrossingFlag = True
            lSuctionValveOpenIndex = i
        End If
        
        i = i + 1
        
    Wend
    
    'Update the value for the function
    bGetSuctionValveOpenIndex = bCrossingFlag

Exit_bGetSuctionValveOpenIndex:
    Exit Function

Error_bGetSuctionValveOpenIndex:
    MsgBox "bGetSuctionValveOpenIndex - " + Err.Description
    Resume Exit_bGetSuctionValveOpenIndex
    
End Function


Public Function bGetWaveformPkPk(dWaveform() As Double, _
                            ByVal lWaveformSampleCount As Long, _
                            ByRef dBandPkPk As Double) As Boolean

On Error GoTo Error_bGetWaveformPkPk

    'local variables
    Dim bTemp As Boolean
    
    bTemp = bGetBandPkPk(dWaveform(0), lWaveformSampleCount, _
                            0, _
                            lWaveformSampleCount, _
                            0, _
                            dBandPkPk)
    'Success
    bGetWaveformPkPk = bTemp

Exit_bGetWaveformPkPk:
    Exit Function

Error_bGetWaveformPkPk:
    MsgBox Err.Description
    Resume Exit_bGetWaveformPkPk
    
End Function

' This function returns an auto-tuned pressure wave and
' the number of samples the waveform was shifted by.
Public Function bGetWaveformPressureAutotune_USCS(lWaveformID As Long, _
                                                    dShiftedWaveform() As Double, _
                                                    lSampleOffset As Long, _
                                                    bAlgorithmSucceded As Boolean, _
                                                    bSuppressErrorMessages As Boolean, _
                                                    lSamplesPerRev As Long) As Boolean

'On Error GoTo Error_bGetWaveformPressureAutotune
    
    'Local variables
    Dim x As String
    Dim Text0 As String
    Dim dCrankAngleArray(131072) As Double
    Dim dWaveform(131072) As Double
    Dim dAverage As Double
    Dim dHysteresis As Double
    Dim dVolumetricEfficiencySuctionArray(131072) As Double
    Dim dVolumetricEfficiencyDischargeArray(131072) As Double
    Dim dClearanceVolumeSuctionArray(131072) As Double
    Dim dClearanceVolumeDischargeArray(131072) As Double
    Dim dValidTDCIndex(131072) As Double
    Dim dAmbientPressure_USCS As Double
    Dim dCompressionRatio As Double
    Dim dClearanceRatio As Double
    Dim dTimeDelta As Double
    Dim dRPM As Double
    Dim dClearanceVolumeRatioThreshold As Double
    Dim lWaveformTypeID As Long
    Dim lWaveformDescriptionID As Long
    Dim lIndex As Long
    Dim lTemp As Long
    Dim lSamples As Long
    Dim lCrossings As Long
    Dim lSubIndexStart As Long
    Dim lSubIndexStop As Long
    Dim lIndexTDC As Long
    Dim lIndexBDC As Long
    Dim lLastTrueIndex As Long
    Dim bTemp As Boolean
    Dim bActiveTrigger As Boolean
    Dim bHeadEndChamber As Boolean
    Dim bDebugOutput As Boolean
    Dim bWrappingSamples As Boolean
    Dim bValidTDCIndex(131072) As Boolean
    
    ' Initialize local variables
    bDebugOutput = False
    bAlgorithmSucceded = False
    
    ' Retrieve the number of samples per revolution
    bTemp = bGetWaveformSamplesPerRev(lWaveformID, _
                                            lSamplesPerRev)
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformPressureAutotune
    End If
    
    ' Check array sizes
    If (UBound(dShiftedWaveform) < lSamplesPerRev) Then
        If (bSuppressErrorMessages = False) Then
            MsgBox "Input array is not long enough in function bGetWaveformPressureAutotune"
        End If
        GoTo Exit_bGetWaveformPressureAutotune
    End If
    
    If (UBound(dWaveform) < lSamplesPerRev) Then
        If (bSuppressErrorMessages = False) Then
            MsgBox "Waveform array is not long enough in function bGetWaveformPressureAutotune"
        End If
        GoTo Exit_bGetWaveformPressureAutotune
    End If
    
    'Convert and retrieve the waveform...error handling
    'in the ModuleDatabase Interface
    bTemp = bGetWaveform_USCS(lWaveformID, dWaveform())
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformPressureAutotune
    End If
    
    ' Is this a cylinder pressure waveform?  If it isn't, then exit
    bTemp = bGetWaveformDescriptionID(lWaveformID, lWaveformDescriptionID)
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformPressureAutotune
    End If
    
    If (lWaveformDescriptionID = 1 Or lWaveformDescriptionID = 6) Then
        bTemp = True
    Else
        bTemp = False
    End If
    If (bTemp = False) Then
        If (bSuppressErrorMessages = False) Then
            MsgBox "This waveform is not a pressure waveform"
        End If
        GoTo Exit_bGetWaveformPressureAutotune
    End If
    
    ' Is this an asynchronous or synchronous waveform?
    bTemp = bGetWaveformTypeID(lWaveformID, lWaveformTypeID)
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformPressureAutotune
    End If
    
    If (lWaveformTypeID = 2 Or lWaveformTypeID = 8) Then
        bTemp = True
    Else
        bTemp = False
    End If
    If (bTemp = True) Then
        
        ' The code needs to extract a single revolution of data from
        ' the asynchronous record.  To do that the average of the
        ' waveform is calculated, then the first two downward crossings are
        ' found.  The first crossing marks the beginning of the
        ' revolution and the second marks the end of the revolution.
        ' A threshold/hysteresis arrangement had to be used as some of the
        ' signals have a bit of noise in them.
        bTemp = bXGetWaveformAverage(dWaveform(0), _
                            lSamplesPerRev, _
                            dAverage)
        If (bTemp = False) Then
            GoTo Exit_bGetWaveformPressureAutotune
        End If
        
        ' With the average calculated, begin the loop through the
        ' data.
        lCrossings = 0
        lSubIndexStart = 0
        lSubIndexStop = 0
        bActiveTrigger = False
        dHysteresis = (dAverage * 0.95)
        For lIndex = 0 To (lSamplesPerRev - 1)
            
            ' Should the trigger be active?
            If (dWaveform(lIndex) < dHysteresis) Then
                bActiveTrigger = True
            End If
            
            ' Is this the first sample below the average?
            If (dWaveform(lIndex) > dAverage And bActiveTrigger = True) Then
                
                ' Is this beginning/end of the waveform?
                Select Case lCrossings
                    Case 0
                    lSubIndexStart = lIndex
                    
                    Case 1
                    lSubIndexStop = lIndex
                    lIndex = lSamplesPerRev
                End Select
                
                ' Increment the crossings and update the trigger
                lCrossings = lCrossings + 1
                bActiveTrigger = False
                
            End If
                
        Next lIndex
        
        ' Did the asyncronous waveform contain at least one revolution?
        If (lCrossings < 2) Then
            If (bSuppressErrorMessages = False) Then
                MsgBox "Failed to find a comple revolution within the waveform"
            End If
            GoTo Exit_bGetWaveformPressureAutotune
        End If
        
        ' Move the subset of the array to front and correct the
        ' samples per revolution variable.
        lSamplesPerRev = (lSubIndexStop - lSubIndexStart)
        For lIndex = 0 To lSamplesPerRev
            dWaveform(lIndex) = dWaveform(lIndex + lSubIndexStart)
        Next lIndex
        
    End If
    
    ' Revolution Extraction Debug
    If (bDebugOutput = True) Then
    
        'Initialize variables for either asynchronous or other
        'cases.
        If (lWaveformTypeID = 2) Then
        
            ' Retrieve the waveform delta time
            bTemp = bGetWaveformDeltaTime(lWaveformID, _
                                            dTimeDelta)
            If (bTemp = False) Then
                GoTo Exit_bGetWaveformPressureAutotune
            End If
            dTimeDelta = (dTimeDelta * CDbl(lSamplesPerRev))
            
        Else
        
            'Retrieve the RPM
            bTemp = bGetWaveformRPM(lWaveformID, dRPM)
            If (bTemp = False) Then
                GoTo Exit_bGetWaveformPressureAutotune
            End If
                
            dTimeDelta = (1# / (dRPM / 60#))
            
        End If
    
        Text0 = ""
        Text0 = Space$(16777216)
    
        lTemp = Len(Text0)
        bTemp = bXGetStringFromArrayAndTime(Text0, _
                                        lTemp, _
                                        dWaveform(0), _
                                        lSamplesPerRev, _
                                        0#, _
                                        dTimeDelta)

        If (bTemp = False) Then
            MsgBox "Exit_CommandCopyWaveformCrankAngleDataTheoreticalAutotuned_Click Failed - External Call to bXGetStringFromArrays02 Failed"
            GoTo Exit_bGetWaveformPressureAutotune
        End If
        
        'puts contents of text0 into clipboard
        x = ClipBoard_SetData(Text0)
        MsgBox "Output from revolution extraction is on the clipboard"
        
    End If
    
    
    
    ' Begin auto-tune section of code here.
    '-----------------------------------------------------------------------------------------
    
    ' Calculate the threshold for acceptable volume ratios.  This has to be
    ' higher as the number of samples increases.
    If (lSamplesPerRev <= 360) Then
        dClearanceVolumeRatioThreshold = 0.12
    Else
        dClearanceVolumeRatioThreshold = 0.08
    End If
    
    
    ' Need to retrieve the chamber orientation (head end / crank end )
    bTemp = bGetWaveformChamber(lWaveformID, bHeadEndChamber)
    If (bTemp = False) Then
        bGetWaveformPressureAutotune_USCS = False
        GoTo Exit_bGetWaveformPressureAutotune
    End If
    
    ' The barometric pressure is required to convert the gage pressures
    ' to absolute pressures.  Error handling and messages at the
    ' DatabaseInterface level.
    bTemp = bGetProcessAmbientPressureByWaveformID_USCS(lWaveformID, _
                                            dAmbientPressure_USCS, _
                                            bSuppressErrorMessages)
    If (bTemp = False) Then
        bGetWaveformPressureAutotune_USCS = False
        GoTo Exit_bGetWaveformPressureAutotune
    End If
    
    ' Step 1:  Is the discharge pressure substantially greater
    ' than the suction pressure?  If it isn't then
    ' it can't be a valid index.  The compression ratio limit
    ' is hard coded to 1.5 below.  This might need to be configurable.
    For lSampleOffset = 0 To lSamplesPerRev
    
        ' Use the array to store a boolean indicating whether
        ' or not the waveform is valid.  The hypothesis is
        ' that the offset is valid.
        bValidTDCIndex(lSampleOffset) = True

        ' Create the indexes to retrieve the suction and discharge
        ' pressure values
        lIndexTDC = lSampleOffset
        lIndexBDC = ((lSampleOffset + (lSamplesPerRev / 2)) Mod lSamplesPerRev)
           
        ' Check to see if the compression ratio is valid
        If (bHeadEndChamber = True) Then
            dCompressionRatio = ((dWaveform(lIndexTDC) + dAmbientPressure_USCS) / (dWaveform(lIndexBDC) + dAmbientPressure_USCS))
        Else
            dCompressionRatio = ((dWaveform(lIndexBDC) + dAmbientPressure_USCS) / (dWaveform(lIndexTDC) + dAmbientPressure_USCS))
        End If
        
        ' Is the compression ratio valid?
        If (dCompressionRatio < 1.4) Then
            bValidTDCIndex(lSampleOffset) = False
        End If
    
    Next lSampleOffset
    
    ' Step 1:  Debug output
    If (bDebugOutput = True) Then
    
        ' Create an array for the crank angle values and
        ' borrow one of the future arrays to store the
        ' double equivalent of the boolean array
        For lIndex = 0 To (lSamplesPerRev - 1)
            dCrankAngleArray(lIndex) = (360# / lSamplesPerRev) * lIndex
            dValidTDCIndex(lIndex) = (-1 * CDbl(bValidTDCIndex(lIndex)))
        Next lIndex
        Text0 = ""
        Text0 = Space$(16777216)
    
        lTemp = Len(Text0)
        bTemp = bXGetStringFromArrays02(Text0, _
                                                lTemp, _
                                                dCrankAngleArray(0), _
                                                lSamplesPerRev, _
                                                dValidTDCIndex(0))
        If (bTemp = False) Then
            MsgBox "Exit_CommandCopyWaveformCrankAngleDataTheoreticalAutotuned_Click Failed - External Call to bXGetStringFromArrays02 Failed"
            GoTo Exit_bGetWaveformPressureAutotune
        End If
        
        'puts contents of text0 into clipboard
        x = ClipBoard_SetData(Text0)
        MsgBox "Output from Step 1 is on the clipboard"
        
    End If
        
    ' Step 2:  Is the suction and discharge volumetric
    ' efficiency valid?  If it isn't, then refute the
    ' hypothesis.
    
    ' Determine the volumetric efficiencies for all
    ' possible piston angles.
    bTemp = bGetWaveformCurveVolumetricEfficienciesAsArray(lWaveformID, _
                                        dWaveform(), _
                                        lSamplesPerRev, _
                                        False, _
                                        dVolumetricEfficiencySuctionArray(), _
                                        dVolumetricEfficiencyDischargeArray(), _
                                        bSuppressErrorMessages)
    
    ' Check that the call to the volumetric efficiency function succeeded.
    If (bTemp = False) Then
        bGetWaveformPressureAutotune_USCS = False
        GoTo Exit_bGetWaveformPressureAutotune
    End If
    
    ' Were the volumetric efficiencies valid?
    For lSampleOffset = 0 To lSamplesPerRev
    
        ' The samples only need to be tested if they passed previous test
        If (bValidTDCIndex(lSampleOffset) = True) Then
            
            ' Is the suction volumetric efficiency valid?
            If (dVolumetricEfficiencySuctionArray(lSampleOffset) >= 1 Or dVolumetricEfficiencySuctionArray(lSampleOffset) <= 0.2) Then
                bValidTDCIndex(lSampleOffset) = False
            End If
            
            ' Is the discharge volumetric efficiency valid?
            If (dVolumetricEfficiencyDischargeArray(lSampleOffset) >= 1 Or dVolumetricEfficiencyDischargeArray(lSampleOffset) <= 0.1) Then
                bValidTDCIndex(lSampleOffset) = False
            End If
            
            ' Is the suction volumetric efficiency greater than the discharge volumetric efficiency?
            If (dVolumetricEfficiencySuctionArray(lSampleOffset) < dVolumetricEfficiencyDischargeArray(lSampleOffset)) Then
                bValidTDCIndex(lSampleOffset) = False
            End If
            
            
        End If
        
    Next lSampleOffset
    
    ' Step 2:  Debug output
    If (bDebugOutput = True) Then
        
        
        ' Create an array for the crank angle values and
        ' borrow one of the future arrays to store the
        ' double equivalent of the boolean array
        For lIndex = 0 To (lSamplesPerRev - 1)
            dCrankAngleArray(lIndex) = (360# / lSamplesPerRev) * lIndex
            dValidTDCIndex(lIndex) = (-1 * CDbl(bValidTDCIndex(lIndex)))
        Next lIndex
        Text0 = ""
        Text0 = Space$(16777216)
    
        lTemp = Len(Text0)
        bTemp = bXGetStringFromArrays02(Text0, _
                                                lTemp, _
                                                dCrankAngleArray(0), _
                                                lSamplesPerRev, _
                                                dValidTDCIndex(0))
        If (bTemp = False) Then
            If (bSuppressErrorMessages = False) Then
                MsgBox "bGetWaveformPressureAutotune Failed - External Call to bXGetStringFromArrays02 Failed"
            End If
            bGetWaveformPressureAutotune_USCS = False
            GoTo Exit_bGetWaveformPressureAutotune
        End If
        
        ' Place the contents of text0 into clipboard
        x = ClipBoard_SetData(Text0)
        MsgBox "Boolean output from Step 2 is on the clipboard"
        
        ' Now for the volumetric efficiency arrays
        For lIndex = 0 To (lSamplesPerRev - 1)
            dCrankAngleArray(lIndex) = (360# / lSamplesPerRev) * lIndex
            dValidTDCIndex(lIndex) = (-1 * CDbl(bValidTDCIndex(lIndex)))
        Next lIndex
        Text0 = ""
        Text0 = Space$(16777216)
    
        lTemp = Len(Text0)
        bTemp = bXGetStringFromArrays03(Text0, _
                                                lTemp, _
                                                dCrankAngleArray(0), _
                                                lSamplesPerRev, _
                                                dVolumetricEfficiencySuctionArray(0), _
                                                dVolumetricEfficiencyDischargeArray(0))
        If (bTemp = False) Then
            If (bSuppressErrorMessages = False) Then
                MsgBox "bGetWaveformPressureAutotune Failed - External Call to bXGetStringFromArrays03 Failed"
            End If
            bGetWaveformPressureAutotune_USCS = False
            GoTo Exit_bGetWaveformPressureAutotune
        End If
        
        ' Place the contents of text0 into clipboard
        x = ClipBoard_SetData(Text0)
        MsgBox "Volumetric efficiency arrays from Step 2 is on the clipboard"
        
    End If
    
    ' Step 3:  Calculate the clearance volumes based on
    ' suction and discharge conditions.  If the clearance
    ' volumes are invalid, refute the validity hypothesis.
    bTemp = bGetWaveformCurveClearanceVolumePercentAsArrays(lWaveformID, _
                                        dWaveform(), _
                                        lSamplesPerRev, _
                                        False, _
                                        dClearanceVolumeSuctionArray(), _
                                        dClearanceVolumeDischargeArray())
    
    ' Did the the clearance volume calculation succeed?
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformPressureAutotune
    End If
    
    ' Were the clearance volumes valid?
    For lSampleOffset = 0 To lSamplesPerRev
    
        ' The samples only need to be tested if they passed previous tests
        If (bValidTDCIndex(lSampleOffset) = True) Then
            
            ' Is the suction clearance volume valid?
            If (dClearanceVolumeSuctionArray(lSampleOffset) < 0.001) Then
                bValidTDCIndex(lSampleOffset) = False
            End If
            
            ' Is the discharge clearance volume valid?
            If (dClearanceVolumeDischargeArray(lSampleOffset) < 0.001) Then
                bValidTDCIndex(lSampleOffset) = False
            End If
            
            ' Is the ratio of the suction clearance close to that of the
            ' clearance volume at discharge conditions?  Check to be certain
            ' we don't divide by zero.
            If (dClearanceVolumeDischargeArray(lSampleOffset) <= 0) Then
                    
                    bValidTDCIndex(lSampleOffset) = False
            
            Else
            
                ' Check to see how close this is to unity
                dClearanceRatio = ((dClearanceVolumeSuctionArray(lSampleOffset) / dClearanceVolumeDischargeArray(lSampleOffset)) - 1#)
                If (Abs(dClearanceRatio) > dClearanceVolumeRatioThreshold) Then
                    bValidTDCIndex(lSampleOffset) = False
                End If
            
            End If
            
        End If
        
    Next lSampleOffset
    
     
    ' Step 3:  Debug output
    If (bDebugOutput = True) Then
        
        
        ' Create an array for the crank angle values and
        ' borrow one of the future arrays to store the
        ' double equivalent of the boolean array
        For lIndex = 0 To (lSamplesPerRev - 1)
            dCrankAngleArray(lIndex) = (360# / lSamplesPerRev) * lIndex
            dValidTDCIndex(lIndex) = (-1 * CDbl(bValidTDCIndex(lIndex)))
        Next lIndex
        Text0 = ""
        Text0 = Space$(16777216)
    
        lTemp = Len(Text0)
        bTemp = bXGetStringFromArrays02(Text0, _
                                                lTemp, _
                                                dCrankAngleArray(0), _
                                                lSamplesPerRev, _
                                                dValidTDCIndex(0))
        If (bTemp = False) Then
            MsgBox "bGetWaveformPressureAutotune Failed - External Call to bXGetStringFromArrays02 Failed"
            GoTo Exit_bGetWaveformPressureAutotune
        End If
        
        ' Place the contents of text0 into clipboard
        x = ClipBoard_SetData(Text0)
        MsgBox "Boolean output from Step 3 is on the clipboard"
        
        ' Now for the clearance volume arrays
        For lIndex = 0 To (lSamplesPerRev - 1)
            dCrankAngleArray(lIndex) = (360# / lSamplesPerRev) * lIndex
            dValidTDCIndex(lIndex) = (-1 * CDbl(bValidTDCIndex(lIndex)))
        Next lIndex
        Text0 = ""
        Text0 = Space$(16777216)
    
        lTemp = Len(Text0)
        bTemp = bXGetStringFromArrays03(Text0, _
                                                lTemp, _
                                                dCrankAngleArray(0), _
                                                lSamplesPerRev, _
                                                dClearanceVolumeSuctionArray(0), _
                                                dClearanceVolumeDischargeArray(0))
        If (bTemp = False) Then
            MsgBox "bGetWaveformPressureAutotune Failed - External Call to bXGetStringFromArrays03 Failed"
            GoTo Exit_bGetWaveformPressureAutotune
        End If
        
        ' Place the contents of text0 into clipboard
        x = ClipBoard_SetData(Text0)
        MsgBox "Clearance volume arrays from Step 3 is on the clipboard"
        
    End If
   
    ' Step 4:  Calculate the flow balance and
    ' see if it meets validity hypothesis
    
    
    ' Step 5: Adjust the waveform by copying it into a
    ' temporary buffer and adjusting by piston angle.
    
    ' This logic tries to find the average location of
    ' the samples that remain true.  The pressure curve
    ' is a cycle so there has to be some accomodation of
    ' the wrapping
    lSampleOffset = 0
    lSamples = 0
    lLastTrueIndex = 0
    bWrappingSamples = False
    For lIndex = 0 To lSamplesPerRev
            
        ' The offset is calculated by taking the average
        ' of the remaning valid candidates.
        If (bValidTDCIndex(lIndex) = True) Then
            
            ' In order for an average to compensate for wrapping,
            ' samples that are far apart need to be compensated.
            ' Set the flag if this condition appears to exist.
            If (lIndex - lLastTrueIndex > (lSamplesPerRev / 2)) Then
                bWrappingSamples = True
            End If
            
            lSampleOffset = (lSampleOffset + lIndex)
            
            lSamples = (lSamples + 1)
            lLastTrueIndex = lIndex
            
        End If
            
    Next lIndex
    
    ' Does compensation need to be made for wrapping?
    If (bWrappingSamples = True) Then
        
        ' Reset the averaging buffer
        lSampleOffset = 0
        lTemp = (lSamplesPerRev / 2)
        For lIndex = 0 To lSamplesPerRev
                
            ' The offset is calculated by taking the average
            ' of the remaning valid candidates.
            If (bValidTDCIndex((lIndex + lTemp) Mod lSamplesPerRev) = True) Then
                
                lSampleOffset = (lSampleOffset + lIndex)
                
            End If
                
        Next lIndex
    
    End If
                
    
    ' Were any candidates left?
    If (lSamples > 0) Then
        
        ' Try to calculate the average result.  Adjust
        ' for wrapping offset, if needed.
        lSampleOffset = CLng(CDbl(lSampleOffset) / CDbl(lSamples))
        If (bWrappingSamples = True) Then
            lSampleOffset = ((lSampleOffset + lTemp) Mod lSamplesPerRev)
        End If
        
        ' Offset the original waveform.
        For lIndex = 0 To lSamplesPerRev
                
            dShiftedWaveform(lIndex) = dWaveform((lIndex + lSampleOffset) Mod lSamplesPerRev)
            
        Next lIndex
        
        ' Change the flag on algorithm success.
        bAlgorithmSucceded = True
        
    Else
        
        ' Display message that algorithm failed, if desired.
        If (bSuppressErrorMessages = False) Then
            MsgBox "Failed to find a suitable offset for top dead center"
        End If
        
    End If
    
    ' Debug - validate the offset
    
    ' End auto-tune section of code
    '-----------------------------------------------------------------------------------------
    
    ' Success
    bGetWaveformPressureAutotune_USCS = True
    
Exit_bGetWaveformPressureAutotune:
    Exit Function

Error_bGetWaveformPressureAutotune:
    MsgBox Err.Description
    Resume Exit_bGetWaveformPressureAutotune
    
End Function

Public Function bGetWaveformCrestFactor(dWaveform() As Double, _
                            ByVal lWaveformSampleCount As Long, _
                            ByRef dBandCrestFactor As Double) As Boolean

On Error GoTo Error_bGetWaveformCrestFactor

    'local variables
    Dim bTemp As Boolean
    Dim dBandPkPk As Double
    Dim dBandRMS As Double
    
    'Calculate the pk-pk of the waveform
    bTemp = bGetBandPkPk(dWaveform(0), lWaveformSampleCount, _
                            0, _
                            lWaveformSampleCount, _
                            0, _
                            dBandPkPk)
    If (bTemp = False) Then
        MsgBox "bGetBandPkPk Failed in bGetWaveformCrestFactor"
        GoTo Exit_bGetWaveformCrestFactor
    End If
    
    'Calculate rms of the waveform
    bTemp = CalcWaveformRMS(dWaveform(0), lWaveformSampleCount, dBandRMS)
    If (bTemp = False) Then
        MsgBox "CalcWaveformRMS Failed in bGetWaveformCrestFactor"
        GoTo Exit_bGetWaveformCrestFactor
    End If
    
    'Validate the numbers, Calculate the crest factor
    If (Abs(dBandRMS) < 0.00000000001) Then
        MsgBox "CalcWaveformRMS Returned a Very Small Value, ~0, in bGetWaveformCrestFactor"
        'GoTo Exit_bGetWaveformCrestFactor
        dBandCrestFactor = 0#
    Else
        dBandCrestFactor = ((dBandPkPk / 2#) / dBandRMS)
    End If
    
    
    'Success
    bGetWaveformCrestFactor = bTemp

Exit_bGetWaveformCrestFactor:
    Exit Function

Error_bGetWaveformCrestFactor:
    MsgBox Err.Description
    Resume Exit_bGetWaveformCrestFactor
    
End Function

' This function returns the percent error, relative to the peak-to-peak
' value of the signal in a waveform.
Public Function bGetWaveformEndPointMatch(dWaveform() As Double, _
                            ByVal lWaveformSampleCount As Long, _
                            ByRef dBandEndPointMatch As Double, _
                            Optional bSuppressWarnings As Boolean) As Boolean

On Error GoTo Error_bGetWaveformEndPointMatch

    'local variables
    Dim bTemp As Boolean
    Dim dBandPkPk As Double
    
    ' Calculate the pk-pk of the waveform
    bTemp = bGetBandPkPk(dWaveform(0), lWaveformSampleCount, _
                            0, _
                            lWaveformSampleCount, _
                            0, _
                            dBandPkPk)
    If (bTemp = False) Then
        If (bSuppressWarnings = False) Then
            MsgBox "bGetBandPkPk Failed in bGetWaveformCrestFactor"
        End If
        GoTo Exit_bGetWaveformEndPointMatch
    End If

    ' We need to divide by the peak to peak value so if it is
    ' less than zero, exit now.
    If (dBandPkPk <= 0#) Then
        bTemp = False
    End If

    ' Calculate the difference between endpoints and normalize
    ' by the total waveform amplitude
    dBandEndPointMatch = Abs(dWaveform(0) - dWaveform(lWaveformSampleCount - 1))
    dBandEndPointMatch = (dBandEndPointMatch / dBandPkPk)
    
    'Success
    bGetWaveformEndPointMatch = bTemp

Exit_bGetWaveformEndPointMatch:
    Exit Function

Error_bGetWaveformEndPointMatch:
    MsgBox Err.Description
    Resume Exit_bGetWaveformEndPointMatch
    
End Function

' This function returns a filtered waveform.  In this case the record
' defines the filter structure rather than including it in the
' arguments.
Public Function bGetWaveformFilteredByRecord(lWaveformID As Long, _
                                                    dFilteredWaveform() As Double, _
                                                    bConvertToUSCS As Boolean, _
                                                    bConvertToMetric As Boolean, _
                                                    Optional bEntireWaveform As Boolean, _
                                                    Optional bSuppressErrorMessages As Boolean) As Boolean

' Establish error trapping
On Error GoTo Error_bGetWaveformFilteredByRecord

    Dim bTemp As Boolean
    Dim bHighPass As Boolean
    Dim bLowPass As Boolean
    Dim bNotchPass As Boolean
    Dim bBandPass As Boolean
    Dim bIsZeroPhase As Boolean
    Dim dHP As Double
    Dim dLP As Double
    Dim dPercentRipple As Double
    Dim lPoleCount As Long
    
    ' Retrieve the waveform
    bTemp = bGetWaveform_USCS(lWaveformID, dFilteredWaveform(), bEntireWaveform)
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformFilteredByRecord
    End If
    
    ' Retrieve the high-pass filter flag.  Error
    ' handling is at that function
    bTemp = bGetWaveformHighPassFilter(lWaveformID, bHighPass, bSuppressErrorMessages)
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformFilteredByRecord
    End If
    
    ' Retrieve the low-pass filter flag.  Error
    ' handling is at that function
    bTemp = bGetWaveformLowPassFilter(lWaveformID, bLowPass)
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformFilteredByRecord
    End If
    
    ' Retrieve the notch-pass filter flag.  Error
    ' handling is at that function
    bTemp = bGetWaveformNotchPassFilter(lWaveformID, bNotchPass)
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformFilteredByRecord
    End If
    
    ' Retrieve the band-pass filter flag.  Error
    ' handling is at that function
    bTemp = bGetWaveformBandPassFilter(lWaveformID, bBandPass)
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformFilteredByRecord
    End If
    
    ' Retrieve the zero-phase filter flag.  Error
    ' handling is at that function
    bTemp = bGetWaveformZeroPhase(lWaveformID, bIsZeroPhase)
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformFilteredByRecord
    End If
    
    ' Retrieve the high-pass corner frequency.  Error
    ' handling is at that function
    bTemp = bGetWaveformHighPass(lWaveformID, dHP, bSuppressErrorMessages)
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformFilteredByRecord
    End If
    
    ' Retrieve the low-pass corner frequency.  Error
    ' handling is at that function
    bTemp = bGetWaveformLowPass(lWaveformID, dLP)
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformFilteredByRecord
    End If
    
    ' Retrieve the percent ripple.  Error
    ' handling is at that function
    bTemp = bGetWaveformPercentRipple(lWaveformID, dPercentRipple)
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformFilteredByRecord
    End If
    
    lPoleCount = 4
    
    ' With the parameters defined, call the other function
    bGetWaveformFilteredByRecord = bGetWaveformFilteredByArgs(lWaveformID, _
                                        dFilteredWaveform(), _
                                        bHighPass, _
                                        bLowPass, _
                                        bNotchPass, _
                                        bBandPass, _
                                        bIsZeroPhase, _
                                        dHP, _
                                        dLP, _
                                        dPercentRipple, _
                                        lPoleCount, _
                                        bConvertToUSCS, _
                                        bConvertToMetric, _
                                        bEntireWaveform)
                                        
Exit_bGetWaveformFilteredByRecord:
    Exit Function

Error_bGetWaveformFilteredByRecord:
    MsgBox Err.Description
    Resume Exit_bGetWaveformFilteredByRecord

End Function


' This function returns a filtered waveform.  In this case the record
' defines the filter structure rather than including it in the
' arguments.
Public Function bGetWaveformSmoothedByRecord_USCS(lWaveformID As Long, _
                                                    dFilteredWaveform() As Double, _
                                                    Optional bReturnAllSamples As Boolean) As Boolean

' Establish error trapping
On Error GoTo Error_bGetWaveformSmoothedByRecord_USCS

    Dim bTemp As Boolean
    Dim lHalfKernelLength As Long
    Dim lSamplesPerRev As Long
    Dim lSampleCount As Long
    
    ' Retrieve the samples per rev
    bTemp = bGetWaveformSamplesPerRev(lWaveformID, lSamplesPerRev)
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformSmoothedByRecord_USCS
    End If
    
    ' To do - this should be replaced with a call to the table
    ' Calculate smoothing parameters based on samples per rev
    bTemp = bGetHalfKernelLength(lSamplesPerRev, _
                                    lHalfKernelLength)
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformSmoothedByRecord_USCS
    End If
    
    ' With the parameters defined, call the other function
    bGetWaveformSmoothedByRecord_USCS = bGetWaveformSmoothedByArgs_USCS(lWaveformID, _
                                        dFilteredWaveform(), _
                                        lHalfKernelLength)
                                        
Exit_bGetWaveformSmoothedByRecord_USCS:
    Exit Function

Error_bGetWaveformSmoothedByRecord_USCS:
    MsgBox Err.Description
    Resume Exit_bGetWaveformSmoothedByRecord_USCS

End Function

' This function returns a filtered waveform.  In this case the arguments
' include the filter information.
Public Function bGetWaveformFilteredByArgs_USCS(lWaveformID As Long, _
                                                        dFilteredWaveform() As Double, _
                                                        bHighPass As Boolean, _
                                                        bLowPass As Boolean, _
                                                        bNotchPass As Boolean, _
                                                        bBandPass As Boolean, _
                                                        bIsZeroPhase As Boolean, _
                                                        dHP As Double, _
                                                        dLP As Double, _
                                                        Optional bEntireWaveform As Boolean) As Boolean
                                                        
' Establish error trapping
On Error GoTo Error_bGetWaveformFilteredByArgs_USCS

    Dim bConvertToUSCS As Boolean
    Dim bConvertToMetric As Boolean
        
    Dim dPercentRipple As Double
    Dim lPoleCount As Long
    
    bConvertToUSCS = True
    bConvertToMetric = True
    dPercentRipple = 0.05
    lPoleCount = 4

    
    bGetWaveformFilteredByArgs_USCS = bGetWaveformFilteredByArgs(lWaveformID, _
                                                        dFilteredWaveform(), _
                                                        bHighPass, _
                                                        bLowPass, _
                                                        bNotchPass, _
                                                        bBandPass, _
                                                        bIsZeroPhase, _
                                                        dHP, _
                                                        dLP, _
                                                        dPercentRipple, _
                                                        lPoleCount, _
                                                        bConvertToUSCS, _
                                                        bConvertToMetric, _
                                                        bEntireWaveform)
                                                        
                                                        
                                                        
Exit_bGetWaveformFilteredByArgs_USCS:
    Exit Function

Error_bGetWaveformFilteredByArgs_USCS:
    MsgBox Err.Description
    Resume Exit_bGetWaveformFilteredByArgs_USCS
    

End Function

' This function returns a filtered waveform.  In this case the arguments
' include the filter information.
Public Function bGetWaveformFilteredByArgs(lWaveformID As Long, _
                                                        dFilteredWaveform() As Double, _
                                                        bHighPass As Boolean, _
                                                        bLowPass As Boolean, _
                                                        bNotchPass As Boolean, _
                                                        bBandPass As Boolean, _
                                                        bIsZeroPhase As Boolean, _
                                                        dHP As Double, _
                                                        dLP As Double, _
                                                        dPercentRipple As Double, _
                                                        lPoleCount As Long, _
                                                        bConvertToUSCS As Boolean, _
                                                        bConvertToMetric As Boolean, _
                                                        Optional bEntireWaveform As Boolean) As Boolean
                                                        
' Establish error trapping
On Error GoTo Error_bGetWaveformFilteredByArgs

    Dim bTemp As Boolean
    Dim bSuppressErrorMessages As Boolean
    Dim lSampleCount As Long
    Dim lTemp As Long
    Dim dRPM As Double
    Dim dSamplingFrequency As Double
    Dim dRevCount As Double
    Dim dWaveform(131070) As Double

    ' Retrieve the waveform.
    bTemp = bGetWaveform(lWaveformID, _
                                    dWaveform(), _
                                    bConvertToUSCS, _
                                    bConvertToMetric, _
                                    bEntireWaveform)
    If (bTemp = False) Then
        MsgBox "Failed to find Waveform for WaveformID " & Str$(lWaveformID)
        bGetWaveformFilteredByArgs = False
        GoTo Exit_bGetWaveformFilteredByArgs
    End If
    
    ' Retrieve the waveform sample count
    If (bEntireWaveform = True) Then
        bTemp = bGetWaveformSampleCount(lWaveformID, lSampleCount)
    Else
        bTemp = bGetWaveformSamplesPerRev(lWaveformID, lSampleCount)
    End If
    If (bTemp = False) Then
        MsgBox "Failed to find Samples per Revolution for WaveformID " & Str$(lWaveformID)
        bGetWaveformFilteredByArgs = False
        GoTo Exit_bGetWaveformFilteredByArgs
    End If
        
    ' If this is a seismic transducer, force AC-Coupled
    bSuppressErrorMessages = False
    bTemp = bGetWaveformCorrectlyCoupled(lWaveformID, _
                            dWaveform(), _
                            lSampleCount, _
                            bSuppressErrorMessages)
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformFilteredByArgs
    End If
    
    ' Retrieve the rpm
    bTemp = bGetWaveformRPM(lWaveformID, dRPM)
    If (bTemp = False) Then
        MsgBox "Failed to find RPM for WaveformID " & Str$(lWaveformID)
        bGetWaveformFilteredByArgs = False
        GoTo Exit_bGetWaveformFilteredByArgs
    End If
    
    ' Retrieve the total revolutions
    bTemp = bGetWaveformRevCount(lWaveformID, _
                                            dRevCount)
    If (bTemp = False) Then
        MsgBox "Failed to find RPM count for WaveformID " & Str$(lWaveformID)
        bGetWaveformFilteredByArgs = False
        GoTo Exit_bGetWaveformFilteredByArgs
    End If
                                        
    ' Calculate the sampling frequency
    If (bEntireWaveform = True) Then
        dSamplingFrequency = ((dRPM / 60#) * (CDbl(lSampleCount)) / dRevCount)
    Else
        dSamplingFrequency = ((dRPM / 60#) * (CDbl(lSampleCount)) / 1)
    End If
    ' Filter the waveform
    lTemp = FilterWaveform(dWaveform(0), _
                dFilteredWaveform(0), _
                lSampleCount, _
                bHighPass, _
                bLowPass, _
                bNotchPass, _
                bBandPass, _
                bIsZeroPhase, _
                dHP, _
                dLP, _
                dSamplingFrequency, _
                dPercentRipple, _
                lPoleCount)

    ' Did the filter work?
    If (lTemp >= 0) Then
        bGetWaveformFilteredByArgs = True
    Else
        MsgBox "FilterWaveform Failed"
        bGetWaveformFilteredByArgs = False
    End If
Exit_bGetWaveformFilteredByArgs:
    Exit Function

Error_bGetWaveformFilteredByArgs:
    MsgBox Err.Description
    Resume Exit_bGetWaveformFilteredByArgs
    

End Function

' This function returns a filtered waveform.  In this case the arguments
' include the filter information.
Public Function bGetWaveformSmoothedByArgs_USCS(lWaveformID As Long, _
                                                        dFilteredWaveform() As Double, _
                                                        lHalfKernelLength As Long) As Boolean
                                                        
' Establish error trapping
On Error GoTo Error_bGetWaveformSmoothedByArgs_USCS

    Dim bTemp As Boolean
    Dim bSuppressErrorMessages As Boolean
    Dim lSamplesPerRev As Long
    Dim dRPM As Double
    Dim dWaveform(131070) As Double

    ' Retrieve the waveform.
    bTemp = bGetWaveform_USCS(lWaveformID, _
                                    dWaveform())
    If (bTemp = False) Then
        MsgBox "Failed to find Waveform for WaveformID " & Str$(lWaveformID)
        bGetWaveformSmoothedByArgs_USCS = False
        GoTo Exit_bGetWaveformSmoothedByArgs_USCS
    End If
    
    ' Retrieve the waveform sample count
    bTemp = bGetWaveformSamplesPerRev(lWaveformID, lSamplesPerRev)
    If (bTemp = False) Then
        MsgBox "Failed to find Samples per Revolution for WaveformID " & Str$(lWaveformID)
        bGetWaveformSmoothedByArgs_USCS = False
        GoTo Exit_bGetWaveformSmoothedByArgs_USCS
    End If
        
    ' If this is a seismic transducer, force AC-Coupled
    bSuppressErrorMessages = False
    bTemp = bGetWaveformCorrectlyCoupled(lWaveformID, _
                            dWaveform(), _
                            lSamplesPerRev, _
                            bSuppressErrorMessages)
    If (bTemp = False) Then
        GoTo Exit_bGetWaveformSmoothedByArgs_USCS
    End If
    
    ' Filter the waveform, return flag for success or failure.
    bGetWaveformSmoothedByArgs_USCS = bXSmoothWaveform(dWaveform(0), _
                dFilteredWaveform(0), _
                lSamplesPerRev, _
                lHalfKernelLength)

Exit_bGetWaveformSmoothedByArgs_USCS:
    Exit Function

Error_bGetWaveformSmoothedByArgs_USCS:
    MsgBox Err.Description
    Resume Exit_bGetWaveformSmoothedByArgs_USCS
    

End Function

' Revision - 13 August 2014
' Added function to calculate the minimum and maximum pressures
Public Function bGetMinMaxPressureAbsolute_USCS(lWaveformID As Long, _
                                        ByRef dPressureMinAbsolute_USCS As Double, _
                                        ByRef dPressureMaxAbsolute_USCS As Double) As Boolean

On Error GoTo Error_bGetMinMaxPressureAbsolute_USCS
            
    'Local variables
    Dim bTemp As Boolean
    Dim lSamplesPerRev As Long
    Dim lSampleIndex As Long
    Dim lWaveformDescriptionID As Long
    Dim lWaveformUnitsID As Long
    Dim dPressure(131070) As Double
    Dim dAmbientPressure_USCS As Double
    
    'Retrieve the waveform in U.S. customary units
    'Error handling at the ModuleDatabaseInterface level
    bTemp = bGetWaveform_USCS(lWaveformID, dPressure())
    If (bTemp = False) Then
        bGetMinMaxPressureAbsolute_USCS = False
        GoTo Exit_bGetMinMaxPressureAbsolute_USCS
    End If
    
    'Retrieve the number of samples...error handling
    'at the ModuleDatabaseInterface level
    bTemp = bGetWaveformSamplesPerRev(lWaveformID, lSamplesPerRev)
    If (bTemp = False) Then
        bGetMinMaxPressureAbsolute_USCS = False
        GoTo Exit_bGetMinMaxPressureAbsolute_USCS
    End If
    
    ' Initialize the min and max variables
    dPressureMinAbsolute_USCS = dPressure(0)
    dPressureMaxAbsolute_USCS = dPressure(0)
    
    ' Loop through the waveform and store away the minimum and maximum values
    For lSampleIndex = 1 To (lSamplesPerRev - 1)
        
        If dPressure(lSampleIndex) < dPressureMinAbsolute_USCS Then
            dPressureMinAbsolute_USCS = dPressure(lSampleIndex)
        End If
        
        If dPressure(lSampleIndex) > dPressureMaxAbsolute_USCS Then
            dPressureMaxAbsolute_USCS = dPressure(lSampleIndex)
        End If
    
    Next lSampleIndex
    
    'If this is a gage pressure curve then add the barometric
    'pressure to get absolute
    bTemp = bGetWaveformUnitsID(lWaveformID, lWaveformUnitsID)
    If (bTemp = False) Then
        bGetMinMaxPressureAbsolute_USCS = False
        GoTo Exit_bGetMinMaxPressureAbsolute_USCS
    End If
    
    If (lWaveformUnitsID = 3 Or lWaveformUnitsID = 11) Then
    
        bTemp = bGetProcessAmbientPressureByWaveformID_USCS(lWaveformID, _
                                            dAmbientPressure_USCS)
        If (bTemp = False) Then
            bGetMinMaxPressureAbsolute_USCS = False
            GoTo Exit_bGetMinMaxPressureAbsolute_USCS
        End If
    
        dPressureMinAbsolute_USCS = (dPressureMinAbsolute_USCS + dAmbientPressure_USCS)
        dPressureMaxAbsolute_USCS = (dPressureMaxAbsolute_USCS + dAmbientPressure_USCS)
    
    End If
        
    bGetMinMaxPressureAbsolute_USCS = True

Exit_bGetMinMaxPressureAbsolute_USCS:
    Exit Function

Error_bGetMinMaxPressureAbsolute_USCS:
    MsgBox "bGetMinMaxPressureAbsolute_USCS - " + Err.Description
    bGetMinMaxPressureAbsolute_USCS = False
    Resume Exit_bGetMinMaxPressureAbsolute_USCS
    
End Function


Public Function bGetPressureWaveformChannelResonance_USCS(lWaveformID As Long, _
                                                        dChannelResonanceWaveform() As Double, _
                                                        dBDCPressure_abs As Double, _
                                                        dTDCPressure_abs As Double) As Boolean
        
        
On Error GoTo Error_bGetPressureWaveformChannelResonance_USCS
        
    'Locals
    Dim bTemp As Boolean
    Dim lSamplesPerRev As Long
    Dim lTemp As Long
    Dim lPressureWaveformIndex As Long
    Dim lPoleCount As Long
    Dim dRPM As Double
    Dim dHP As Double
    Dim dLP As Double
    Dim dSamplingFrequency As Double
    Dim dAmbientPressure_USCS As Double
    Dim dPercentRipple As Double
    Dim dPressureWaveform(131070) As Double
    Dim dHPFilteredWaveform(131070) As Double
    Dim dLPFilteredWaveform(131070) As Double
    
    'Retrieve the pressure waveform
    bTemp = bGetWaveform_USCS(lWaveformID, _
                                    dPressureWaveform())
    If (bTemp = False) Then
        MsgBox "Failed to find Pressure Waveform for WaveformID " & Str$(lWaveformID)
        bGetPressureWaveformChannelResonance_USCS = False
        GoTo Exit_bGetPressureWaveformChannelResonance_USCS
    End If
    
    'Retrieve the waveform sample count
    bTemp = bGetWaveformSamplesPerRev(lWaveformID, lSamplesPerRev)
    If (bTemp = False) Then
        MsgBox "Failed to find Samples per Revolution for WaveformID " & Str$(lWaveformID)
        bGetPressureWaveformChannelResonance_USCS = False
        GoTo Exit_bGetPressureWaveformChannelResonance_USCS
    End If
        
    'Retrieve the rpm
    bTemp = bGetWaveformRPM(lWaveformID, dRPM)
    If (bTemp = False) Then
        MsgBox "Failed to find RPM for WaveformID " & Str$(lWaveformID)
        bGetPressureWaveformChannelResonance_USCS = False
        GoTo Exit_bGetPressureWaveformChannelResonance_USCS
    End If
                                        
    'notch-pass Filter the waveform
    dSamplingFrequency = ((dRPM / 60#) * lSamplesPerRev)
    dHP = ((dRPM / 60#) * 20#)
    dLP = ((dRPM / 60#) * 40#)
    dPercentRipple = 0.5
    lPoleCount = 4
    lTemp = FilterWaveform(dPressureWaveform(0), _
                dHPFilteredWaveform(0), _
                lSamplesPerRev, _
                False, _
                False, _
                True, _
                False, _
                True, _
                dHP, _
                dLP, _
                dSamplingFrequency, _
                dPercentRipple, _
                lPoleCount)
    
    'Retrieve the barometric pressure
    bTemp = bGetProcessAmbientPressureByWaveformID_USCS(lWaveformID, _
                                        dAmbientPressure_USCS)
    If (bTemp = False) Then
        MsgBox "Failed to find Ambient Pressure for WaveformID " & Str$(lWaveformID)
        bGetPressureWaveformChannelResonance_USCS = False
        GoTo Exit_bGetPressureWaveformChannelResonance_USCS
    End If
    
    'Characterize the values
    lPressureWaveformIndex = 0
    dTDCPressure_abs = (dHPFilteredWaveform(0) + dAmbientPressure_USCS)
    dBDCPressure_abs = (dHPFilteredWaveform(lSamplesPerRev / 2) + dAmbientPressure_USCS)
    
    'If the pressure at top dead center is less than
    'the pressure at bottom dead center this is the crank end
    If (dPressureWaveform(0) > dPressureWaveform(lSamplesPerRev / 2)) Then
        
        While (lPressureWaveformIndex < lSamplesPerRev)
            
            If (((dHPFilteredWaveform(lPressureWaveformIndex) + dAmbientPressure_USCS) > (dBDCPressure_abs * 1.15)) And ((dHPFilteredWaveform(lPressureWaveformIndex) + dAmbientPressure_USCS) < (dTDCPressure_abs * 0.85))) Then
                dChannelResonanceWaveform(lPressureWaveformIndex) = dHPFilteredWaveform(lPressureWaveformIndex)
            Else
                dChannelResonanceWaveform(lPressureWaveformIndex) = 0
            End If
            'Text0 = Text0 + Str$(dChannelResonanceWaveform(lPressureWaveformIndex)) + Chr(9)
            
            lPressureWaveformIndex = (lPressureWaveformIndex + 1)
        
        Wend
    
    Else
        
        While (lPressureWaveformIndex < lSamplesPerRev)
            
            If (((dHPFilteredWaveform(lPressureWaveformIndex) + dAmbientPressure_USCS) < (dBDCPressure_abs * 0.85)) And ((dHPFilteredWaveform(lPressureWaveformIndex) + dAmbientPressure_USCS) > (dTDCPressure_abs * 1.15))) Then
                dChannelResonanceWaveform(lPressureWaveformIndex) = dHPFilteredWaveform(lPressureWaveformIndex)
            Else
                dChannelResonanceWaveform(lPressureWaveformIndex) = 0
            End If
            'Text0 = Text0 + Str$(dChannelResonanceWaveform(lPressureWaveformIndex)) + Chr(9)
            
            lPressureWaveformIndex = (lPressureWaveformIndex + 1)
        
        Wend
    
    End If
    
    bGetPressureWaveformChannelResonance_USCS = True
        
Exit_bGetPressureWaveformChannelResonance_USCS:
    Exit Function

Error_bGetPressureWaveformChannelResonance_USCS:
    MsgBox Err.Description
    Resume Exit_bGetPressureWaveformChannelResonance_USCS
    
End Function
Public Function bGetBandPkPk_String(sWaveform As String, _
                            ByVal lWaveformSamples As Long, _
                            ByVal lBandAnchor As Long, _
                            ByVal lBandSampleCount As Long, _
                            ByVal lBandOffsetSampleCount As Long, _
                            ByRef dBandPkPk As Double) As Boolean

On Error GoTo Error_bGetBandPkPk_String

    'local variables
    Dim dWaveform(1024) As Double
    Dim bTemp As Boolean
    Dim lColsFound As Long

    'Convert to a double array and check for success
    bTemp = bXGetRowAsDoubleArray(sWaveform, dWaveform(0), 1024, 1, lColsFound)
    
    If (bTemp = False) Then
        bGetBandPkPk_String = False
        GoTo Exit_bGetBandPkPk_String
    End If
    
    'With the conversion in place, use call the function
    'that uses an array
    bTemp = bGetBandPkPk(dWaveform(0), _
                            lWaveformSamples, _
                            lBandAnchor, _
                            lBandSampleCount, _
                            lBandOffsetSampleCount, _
                            dBandPkPk)
    
    'Success
    bGetBandPkPk_String = bTemp
    
Exit_bGetBandPkPk_String:
    Exit Function

Error_bGetBandPkPk_String:
    MsgBox Err.Description
    Resume Exit_bGetBandPkPk_String
    
End Function

'Integrate an arbitrary waveform
Public Function bIntegrateWaveform(ByVal lWaveformID As Long, _
                                        ByRef dWaveformIntegrated_USCS() As Double, _
                                        ByRef dTimeDelta As Double) As Boolean


On Error GoTo Err_bIntegrateWaveform
    
    'Local variables
    Dim sTemp As String
    Dim dWaveform(131070) As Double
    Dim dIntegrationStep As Double
    Dim dRPM As Double
    Dim dUnitConversion As Double
    Dim dTemp As Double
    Dim lWaveformSampleCount As Long
    Dim lWaveformTypeID As Long
    Dim lWaveformUnitsID As Long
    Dim lIndex As Long
    Dim lTemp As Long
    Dim bTemp As Boolean
    Dim bSuppressErrorMessages As Boolean
    
    ' Retrieve the waveform samplecount
    bTemp = bGetWaveformSamplesPerRev(lWaveformID, lWaveformSampleCount)
    If (bTemp = False) Then
        GoTo Exit_bIntegrateWaveform
    End If
    
    ' Validate array length
    If (UBound(dWaveformIntegrated_USCS, 1) < lWaveformSampleCount) Then
        MsgBox "Input array size is smaller than waveform sample count"
        GoTo Exit_bIntegrateWaveform
    End If
    
    'Convert and retrieve the waveform...error handling
    'in the ModuleDatabase Interface
    bTemp = bGetWaveform_USCS(lWaveformID, dWaveform())
    If (bTemp = False) Then
        GoTo Exit_bIntegrateWaveform
    End If
    
    ' If this is a seismic transducer, force AC-Coupled
    bSuppressErrorMessages = False
    bTemp = bGetWaveformCorrectlyCoupled(lWaveformID, _
                            dWaveform(), _
                            lWaveformSampleCount, _
                            bSuppressErrorMessages)
    If (bTemp = False) Then
        GoTo Exit_bIntegrateWaveform
    End If
    
    'Variable initialization depends upon the type of waveform
    bTemp = bGetWaveformTypeID(lWaveformID, lWaveformTypeID)
    If (bTemp = False) Then
        GoTo Exit_bIntegrateWaveform
    End If

    'Retrieve the RPM for any kind of synchronous waveform,
    'skip it for the asynchronous
    If (lWaveformTypeID <> 2) Then
        bTemp = bGetWaveformRPM(lWaveformID, dRPM)
        If (bTemp = False) Then
            GoTo Exit_bIntegrateWaveform
        End If
    End If
    
    'Calculate the delta time for each sample
    If (lWaveformTypeID = 2) Then
        
        bTemp = bGetWaveformDeltaTime(lWaveformID, dTimeDelta)
        If (bTemp = False) Then
            GoTo Exit_bIntegrateWaveform
        End If
        dTimeDelta = (dTimeDelta * CDbl(lWaveformSampleCount))
        
    Else
    
        dTimeDelta = (1# / (dRPM / 60#))
        
    End If
    
    'Normalize the data
    dTemp = 0#
    For lTemp = 0 To (lWaveformSampleCount - 1)
        dTemp = dTemp + dWaveform(lTemp)
    Next lTemp
    dTemp = (dTemp / lWaveformSampleCount)
    For lTemp = 0 To (lWaveformSampleCount - 1)
        dWaveform(lTemp) = dWaveform(lTemp) - dTemp
    Next lTemp
    
    ' Need to retrieve the waveform units to that the appropriate
    ' unit conversions can be applied
    lWaveformUnitsID = 0
    bTemp = bGetWaveformUnitsID(lWaveformID, lWaveformUnitsID)
    If (bTemp = False) Then
        GoTo Exit_bIntegrateWaveform
    End If
    
    ' Establish correct scale factors
    Select Case lWaveformUnitsID
        
        'This is acceleration (g's)
        Case 1
        
            ' From g's to ft/s2 to in/s2
            dUnitConversion = 32.2 * 12
        
        'This is velocity (in/s)
        Case 13
            
            'From inches/s to mils/s
            dUnitConversion = 1000#
        
        ' The default
        Case Else
            dUnitConversion = 1#
    
    End Select
    
    'integrate the data (assumed to be acceleration to velocity)
    dTemp = 0#
    dIntegrationStep = (dTimeDelta / CDbl(lWaveformSampleCount))
    For lTemp = 0 To (lWaveformSampleCount - 1)
        lIndex = (lTemp + 1) Mod lWaveformSampleCount
        dTemp = dTemp + (dUnitConversion * dIntegrationStep * (dWaveform(lTemp) + dWaveform(lIndex)))
        dWaveformIntegrated_USCS(lTemp) = dTemp
    Next lTemp
    
    bIntegrateWaveform = True
    Exit Function
    
Exit_bIntegrateWaveform:
    bIntegrateWaveform = False
    Exit Function

Err_bIntegrateWaveform:
    MsgBox Err.Description
    Resume Exit_bIntegrateWaveform


End Function


'Shift the piston angle of a waveform
Public Function bShiftPistonAngle(ByVal dPistonAngleWaveformDesired As Double, _
                                            ByVal dPistonAngleWaveformAsFound As Double, _
                                            ByVal lSamplesPerRev As Long, _
                                            ByRef dWaveform() As Double) As Boolean
                                            
On Error GoTo Error_bShiftPistonAngle
    
    'local variables
    Dim lTemp As Long
    Dim lIndex As Long
    Dim lIndexPistonAngleShift As Long
    Dim dPistonAngleShift As Double
    Dim dWaveformTemp() As Double
    
    'initialize locals
    dPistonAngleShift = (dPistonAngleWaveformDesired - dPistonAngleWaveformAsFound)
    lIndexPistonAngleShift = ((lSamplesPerRev / 360#) * dPistonAngleShift)
    ReDim dWaveformTemp(0 To UBound(dWaveform, 1))
    
    'Shift the array into a temporary one
    For lTemp = 0 To lSamplesPerRev
    
        lIndex = (lIndexPistonAngleShift + lTemp + lSamplesPerRev) Mod lSamplesPerRev
        dWaveformTemp(lTemp) = dWaveform(lIndex)
    
    Next lTemp
    
    'Copy shifted back into the original
    For lTemp = 0 To lSamplesPerRev
    
        dWaveform(lTemp) = dWaveformTemp(lTemp)
    
    Next lTemp
    
    'Success
    bShiftPistonAngle = True
    
Exit_bShiftPistonAngle:
    Exit Function

Error_bShiftPistonAngle:
    MsgBox Err.Description
    Resume Exit_bShiftPistonAngle

End Function

'Piston rod vibration signals may have significant subsynchronous components
'resulting in a discontinuity at the waveform end points.  This appears as
'an impulse event to the filter so the following calculations smooth the end of the curve
Public Function bSmoothWaveformEnds(ByRef dWaveform() As Double, _
                                        ByVal lWaveformSampleCount As Double) As Boolean
                                        

On Error GoTo Error_bSmoothWaveformEnds
    
    'Local variables
    Dim bTemp As Boolean
    Dim dIndepArray(1024) As Double
    Dim dDepArray(1024) As Double
    Dim dSlope As Double
    Dim dIntercept As Double
    Dim lWaveformEndSmoothingCount As Long
    Dim lTemp As Long
    Dim lTemp02 As Long
    Dim lArraySize As Long
    
    'Calculate the number of points involved in the smoothing
    lWaveformEndSmoothingCount = (lWaveformSampleCount / 100)
    lArraySize = (lWaveformEndSmoothingCount * 2)
    
    'check bounds on the array
    If (lArraySize > UBound(dIndepArray, 1)) Then
        MsgBox "Smoothing points, " + Str$(lArraySize) + ", larger than dIndepArray size, " + Str$(UBound(dIndepArray, 1)) + "."
        GoTo Exit_bSmoothWaveformEnds
    End If
    'check bounds on the array
    If (lArraySize > UBound(dDepArray, 1)) Then
        MsgBox "Smoothing points, " + Str$(lArraySize) + ", larger than dDepArray size, " + Str$(UBound(dDepArray, 1)) + "."
        GoTo Exit_bSmoothWaveformEnds
    End If
    
    'Create the independent and dependent double array
    For lTemp = 1 To lArraySize
        dIndepArray(lTemp - 1) = (lTemp * (360 / lWaveformSampleCount))
        lTemp02 = ((lWaveformSampleCount - lWaveformEndSmoothingCount) + (lTemp - 1))
        If (lTemp02 >= lWaveformSampleCount) Then
            lTemp02 = (lTemp02 - lWaveformSampleCount)
        End If
        dDepArray(lTemp - 1) = dWaveform(lTemp02)
    Next lTemp
    
    'Force the line to start at first sample and end at the last sample
    dSlope = (dDepArray(lArraySize - 1) - dDepArray(0)) / (dIndepArray(lArraySize - 1) - dIndepArray(0))
    dIntercept = dDepArray(0)
    
    'Over write the original data with the linear fit
    For lTemp = 1 To lArraySize
        lTemp02 = ((lWaveformSampleCount - lWaveformEndSmoothingCount) + (lTemp - 1))
        If (lTemp02 >= lWaveformSampleCount) Then
            lTemp02 = (lTemp02 - lWaveformSampleCount)
        End If
        dWaveform(lTemp02) = dIntercept + (dSlope * (dIndepArray(lTemp - 1) - dIndepArray(0)))
    Next lTemp
    
    'Success
    bSmoothWaveformEnds = True
    
Exit_bSmoothWaveformEnds:
    Exit Function

Error_bSmoothWaveformEnds:
    MsgBox "bSmoothWaveformEnds - " + Err.Description
    Resume Exit_bSmoothWaveformEnds
    
End Function
                                        
Public Function bGetFilteredPistonRodBandPkPk_RecordSet(ByRef rstWaveform As Recordset, _
                            ByVal lMaxRecord As Long, _
                            ByVal lBandAnchor As Long, _
                            ByVal lBandSampleCount As Long, _
                            ByVal lBandOffsetSampleCount As Long, _
                            ByVal dRPM As Double, _
                            ByRef dBandPkPk() As Double) As Boolean

On Error GoTo Error_bGetFilteredPistonRodBandPkPk_RecordSet

    'local variables
    Dim dWaveform(1024) As Double
    Dim dPistonRodDataFiltered(1024) As Double
    Dim dHP As Double
    Dim dLP As Double
    Dim dSamplingFrequency As Double
    Dim dPercentRipple As Double
    Dim bTemp As Boolean
    Dim bHighPass As Boolean
    Dim bLowPass As Boolean
    Dim bNotchPass As Boolean
    Dim bBandPass As Boolean
    Dim bIsZeroPhase As Boolean
    Dim sTemp As String
    Dim lTemp As Long
    Dim lRecordCount As Long
    Dim lRecordIndex As Long
    Dim lSamplesPerRev As Long
    Dim lPoleCount As Long
    
    'initialize local variables
    For lTemp = 0 To (lMaxRecord - 1)
        dBandPkPk(lTemp) = 0
    Next lTemp

    'If crosshead accel records were found, extract the data
    If (rstWaveform.RecordCount > 0) Then
    
        'Count number of records to be exported
        lRecordCount = rstWaveform.RecordCount
        
        'loop to extract the band data
        lRecordIndex = 0
        rstWaveform.MoveFirst
        While (lRecordIndex < lRecordCount)
            
            'Retrieve waveform information from database
            sTemp = rstWaveform("WaveformExtracted")
            lSamplesPerRev = rstWaveform("WaveformSampleCount")
    
            'Convert to a double array and check for success
            bTemp = bXGetRowAsDoubleArray(sTemp, dWaveform(0), 1024, 1, lTemp)
            
            'Filter the waveform and evaluate statistically
            dSamplingFrequency = ((dRPM / 60) * lSamplesPerRev)
            dHP = ((dRPM / 60) * 80)
            dLP = ((dRPM / 60) * 80)
            bHighPass = True
            bLowPass = False
            bNotchPass = False
            bBandPass = False
            bIsZeroPhase = True
            dPercentRipple = 0.5
            lPoleCount = 4
            lTemp = FilterWaveform(dWaveform(0), _
                        dPistonRodDataFiltered(0), _
                        lSamplesPerRev, _
                        bHighPass, _
                        bLowPass, _
                        bNotchPass, _
                        bBandPass, _
                        bIsZeroPhase, _
                        dHP, _
                        dLP, _
                        dSamplingFrequency, _
                        dPercentRipple, _
                        lPoleCount)
            
            'Calculate the pk-pk value
            bTemp = bGetBandPkPk(dPistonRodDataFiltered(0), _
                                    lSamplesPerRev, _
                                    lBandAnchor, _
                                    lBandSampleCount, _
                                    lBandOffsetSampleCount, _
                                    dBandPkPk(lRecordIndex))
           
            rstWaveform.MoveNext
            lRecordIndex = lRecordIndex + 1
        
        Wend
        
    End If
    
    'Success
    bGetFilteredPistonRodBandPkPk_RecordSet = True
    
Exit_bGetFilteredPistonRodBandPkPk_RecordSet:
    Exit Function

Error_bGetFilteredPistonRodBandPkPk_RecordSet:
    MsgBox Err.Description
    Resume Exit_bGetFilteredPistonRodBandPkPk_RecordSet
    
End Function


