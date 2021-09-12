package com.example.sharing_app


import android.Manifest
import android.annotation.SuppressLint
import android.database.Cursor
import io.flutter.embedding.android.FlutterActivity
import android.provider.ContactsContract

import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.telephony.TelephonyManager
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

class MainActivity: FlutterActivity() {

    private final val channel: String = "samples.flutter.dev/sharing_app"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channel
        ).setMethodCallHandler { call, result ->
            if (call.method == "getContactList") {
                val data = getContactList();
                result.success(data)
            } else if (call.method == "getPhoneNumber") {
                val phoneNumber = getPhoneNumber();
                result.success(phoneNumber)
            } else if (call.method == "requestReadContactsPermissions") {
                val permission = requestReadContactsPermissions();
                result.success(permission.toString())
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getContactList(): MutableList<Map<String, String>> {
        var userList = mutableListOf<Map<String, String>>()
        var phones: Cursor? = contentResolver.query(
            ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
            null,
            null,
            null,
            null
        );
        while (phones != null && phones.moveToNext()) {
            val name: String =
                phones.getString(phones.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME));
            val phoneNumber: String =
                phones.getString(phones.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER));
            userList.add(
                mapOf<String, String>(
                    "registered_user_name" to name,
                    "registered_user_phone" to phoneNumber
                )
            );
        }

        return userList;
    }

    private fun getPhoneNumber(): String {
        val teleMamanger: TelephonyManager =
            getSystemService(Context.TELEPHONY_SERVICE) as TelephonyManager
        val getSimNumber: Unit = if (ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.READ_SMS
            ) == PackageManager.PERMISSION_GRANTED || ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.READ_PHONE_NUMBERS
            ) == PackageManager.PERMISSION_GRANTED || ActivityCompat.checkSelfPermission(
                this,
                Manifest.permission.READ_PHONE_STATE
            ) == PackageManager.PERMISSION_GRANTED
        ) {
            return teleMamanger.line1Number;
        } else {
            return "0000000000";
        }
    }

    private fun requestReadContactsPermissions(): Boolean {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_CONTACTS) !==
            PackageManager.PERMISSION_GRANTED
        ) {
            if (ActivityCompat.shouldShowRequestPermissionRationale(
                    this@MainActivity,
                    Manifest.permission.READ_CONTACTS
                )
            ) {
                ActivityCompat.requestPermissions(
                    this@MainActivity,
                    arrayOf(Manifest.permission.READ_CONTACTS), 1
                )
            } else {
                ActivityCompat.requestPermissions(
                    this@MainActivity,
                    arrayOf(Manifest.permission.READ_CONTACTS), 1
                )
            }

            return false;
        } else {
            return true;
        }
    }
}