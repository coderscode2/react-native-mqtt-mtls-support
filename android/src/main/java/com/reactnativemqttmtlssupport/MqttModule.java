package com.reactnativemqttmtlssupport;

import android.util.Log;

import androidx.annotation.NonNull;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Promise;

public class MqttModule extends ReactContextBaseJavaModule {
  private static final String MODULE_NAME = "MqttModule";

  public MqttModule(ReactApplicationContext reactContext) {
    super(reactContext);
  }

  @NonNull
  @Override
  public String getName() {
    return MODULE_NAME;
  }

  @ReactMethod
  public void connectWithMtls(String brokerUrl, String clientId, String cert, String key, Promise promise) {
    try {
      // You would replace this with actual MQTT + mTLS logic
      Log.d(MODULE_NAME, "Connecting to broker: " + brokerUrl + " with clientId: " + clientId);
      Log.d(MODULE_NAME, "Cert: " + cert.substring(0, 20) + "...");
      Log.d(MODULE_NAME, "Key: " + key.substring(0, 20) + "...");
      promise.resolve("Connected to " + brokerUrl);
    } catch (Exception e) {
      promise.reject("CONNECT_ERROR", "Failed to connect to MQTT broker", e);
    }
  }
}
