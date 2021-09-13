using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Square : MonoBehaviour
{
    bool isStarted = false;
    // Start is called before the first frame update
    void Start()
    {
        BleReceiver.Instance.onDidBleManagerChangeState += onDidBleManagerChangeState;
        BleReceiver.Instance.onDidScanTimeOut += onDidScanTimeOut;
        BleReceiver.Instance.onDidConnectPeripheral += onDidConnectPeripheral;
        BleReceiver.Instance.onDidDiscoverZealLe0 += onDidDiscoverZealLe0;
        BleReceiver.Instance.onDidReceiveBloodPressureData += onDidReceiveBloodPressureData;
        BleReceiver.Instance.onDeviceDidChangeStatePowerOff += onDeviceDidChangeStatePowerOff;
        BleReceiver.Instance.onDidUpdateMeasureStep += onDidUpdateMeasureStep;
    }

    // Update is called once per frame
    void Update()
    {
        if (!isStarted) {
            BleReceiver.InitBleManager();
            isStarted = true;
        }
    }

    void onDidBleManagerChangeState(string state) {
        Debug.Log("onDidBleManagerChangeState: state = " + state);
        if (state == "5") {
            BleReceiver.StartScan();
        }
        else {
           Debug.Log("Iphone's bluetooth is not On"); 
        }
    }

    void onDidScanTimeOut() {
        Debug.Log("onDidScanTimeOut");
    }

    void onDidConnectPeripheral(string state) {
        Debug.Log("onDidConnectPeripheral: state = " + state);
    }

    void onDidDiscoverZealLe0(string device) {
        Debug.Log("onDidDiscoverZealLe0: " + device);
    }

    void onDidReceiveBloodPressureData(string data) {
        Debug.Log("onDidReceiveBloodPressureData: " + data);
    }

    void onDeviceDidChangeStatePowerOff() {
        Debug.Log("onDeviceDidChangeStatePowerOff");
    }
    
    void onDidUpdateMeasureStep(string data) {
        Debug.Log("onDidUpdateMeasureStep: " + data);
    }
}