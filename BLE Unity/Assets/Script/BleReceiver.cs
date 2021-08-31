using System;
using System.Runtime.InteropServices;
using UnityEngine;

public class BleReceiver : MonoBehaviour
{

    #region Declare external C interface

    #if UNITY_IOS && !UNITY_EDITOR
            
    [DllImport("__Internal")]
    private static extern void _InitBleManager();

    [DllImport("__Internal")]
    private static extern void _StartScan();

    [DllImport("__Internal")]
    private static extern void _StopScan();

    [DllImport("__Internal")]
    private static extern string _RetrieveConnectedDevices();

    [DllImport("__Internal")]
    private static extern void _ConnectToScanDeviceWith(string identifier);

    [DllImport("__Internal")]
    private static extern void _StartMeasureBloodPressure();

    [DllImport("__Internal")]
    private static extern void _DisconnectDevice();
        
    #endif

    #endregion

    #region Wrapped methods and properties

    public static void InitBleManager()
    {
        #if UNITY_IOS && !UNITY_EDITOR
            _InitBleManager();
        #else
            Debug.Log("No Swift found!");
        #endif
    }

    public static void StartScan()
    {
        #if UNITY_IOS && !UNITY_EDITOR
            _StartScan();
        #else
            Debug.Log("No Swift found!");
        #endif
    }

    public static void StopScan()
    {
        #if UNITY_IOS && !UNITY_EDITOR
            _StopScan();
        #else
            Debug.Log("No Swift found!");
        #endif
    }

    public static string RetrieveConnectedDevices()
    {
        #if UNITY_IOS && !UNITY_EDITOR
            return _RetrieveConnectedDevices();
        #else
            return "No Swift found!";
        #endif
    }

    public static void ConnectToScanDeviceWith(string identifier)
    {
        #if UNITY_IOS && !UNITY_EDITOR
            _ConnectToScanDeviceWith(identifier);
        #else
            Debug.Log("No Swift found!");
        #endif
    }

    public static void StartMeasureBloodPressure()
    {
        #if UNITY_IOS && !UNITY_EDITOR
            _StartMeasureBloodPressure();
        #else
            Debug.Log("No Swift found!");
        #endif
    }

    public static void DisconnectDevice()
    {
        #if UNITY_IOS && !UNITY_EDITOR
            _DisconnectDevice();
        #else
            Debug.Log("No Swift found!");
        #endif
    }

    #endregion

    #region Singleton implementation

    private static BleReceiver _instance;

    public static BleReceiver Instance
    {
        get
        {
            if (_instance == null)
            {
                var obj = new GameObject("BleReceiver");
                _instance = obj.AddComponent<BleReceiver>();
            }

            return _instance;
        }
    }

    void Awake()
    {
        if (_instance != null)
        {
            Destroy(gameObject);
            return;
        }

        DontDestroyOnLoad(gameObject);
    }

    public System.Action<string> onDidBleManagerChangeState;
    public System.Action onDidScanTimeOut;
    public System.Action<string> onDidConnectPeripheral;
    public System.Action<string> onDidDiscoverZealLe0;
    public System.Action<string> onDidReceiveBloodPressureData;
    public System.Action onDeviceDidChangeStatePowerOff;
    public System.Action<string> onDidUpdateMeasureStep;

    public void DidBleManagerChangeStateWith(string state) {
        if (onDidBleManagerChangeState != null) {
            onDidBleManagerChangeState.Invoke(state);
        }
    }

    public void DidScanTimeOut() {
        if (onDidScanTimeOut != null) {
            onDidScanTimeOut.Invoke();
        }
    }

    public void DidConnectPeripheralWith(string state) {
        if (onDidConnectPeripheral != null) {
            onDidConnectPeripheral.Invoke(state);
        }
    }

    public void DidDiscoverZealLe0(string device) {
        if (onDidDiscoverZealLe0 != null) {
            onDidDiscoverZealLe0.Invoke(device);
        }
    }

    public void DidReceiveBloodPressureData(string data) {
        if (onDidReceiveBloodPressureData != null) {
            onDidReceiveBloodPressureData.Invoke(data);
        }
    }

    public void DeviceDidChangeStatePowerOff() {
        if (onDeviceDidChangeStatePowerOff != null) {
            onDeviceDidChangeStatePowerOff.Invoke();
        }
    }

    public void DidUpdateMeasureStep(string data) {
        if (onDidUpdateMeasureStep != null) {
            onDidUpdateMeasureStep.Invoke(data);
        }
    }
    #endregion
}