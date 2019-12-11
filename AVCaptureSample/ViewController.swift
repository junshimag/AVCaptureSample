//
//  ViewController.swift
//  AVCaptureSample
//
//  Created by lc_shimaguchi on 2019/12/12.
//  Copyright © 2019 lc_shimaguchi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,AVCaptureVideoDataOutputSampleBufferDelegate {

    // デバイスからの入力と出力を管理するオブジェクトの作成
    var captureSession = AVCaptureSession()
    // カメラデバイスそのものを管理するオブジェクトの作成
    // メインカメラの管理オブジェクトの作成
    var mainCamera: AVCaptureDevice?
    // インカメの管理オブジェクトの作成
    var innerCamera: AVCaptureDevice?
    // 現在使用しているカメラデバイスの管理オブジェクトの作成
    var currentDevice: AVCaptureDevice?
    // キャプチャーの出力データを受け付けるオブジェクト
    var videoOutput = AVCaptureVideoDataOutput()
    // プレビュー表示用のレイヤ
    var cameraPreviewLayer : AVCaptureVideoPreviewLayer?
    
    var rectView = UIView()
    
    var rectX = 0
    var rectY = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        captureSession.startRunning()
        self.rectView.layer.borderWidth = 3//四角い枠を用意しておく
        self.rectView.layer.borderColor = UIColor.green.cgColor
        self.view.addSubview(self.rectView)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

//MARK: カメラ設定メソッド
extension ViewController{
    // カメラの画質の設定
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    // デバイスの設定
    func setupDevice() {
        // カメラデバイスのプロパティ設定
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        // プロパティの条件を満たしたカメラデバイスの取得
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                mainCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                innerCamera = device
            }
        }
        // 起動時のカメラを設定
        currentDevice = mainCamera
    }
    
    // 入出力データの設定
    func setupInputOutput() {
        do {
            // 指定したデバイスを使用するために入力を初期化
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            // 指定した入力をセッションに追加
            captureSession.addInput(captureDeviceInput)
            // 出力データを受け取るオブジェクトの作成
            videoOutput = AVCaptureVideoDataOutput()

            let queue:DispatchQueue = DispatchQueue(label: "myqueue", attributes: .concurrent)
            
            videoOutput.setSampleBufferDelegate(self, queue: queue)
            videoOutput.alwaysDiscardsLateVideoFrames = true
            
            captureSession.addOutput(videoOutput)
        } catch {
            print(error)
        }
    }
    
    // カメラのプレビューを表示するレイヤの設定
    func setupPreviewLayer() {
        // 指定したAVCaptureSessionでプレビューレイヤを初期化
        self.cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // プレビューレイヤが、カメラのキャプチャーを縦横比を維持した状態で、表示するように設定
        self.cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // プレビューレイヤの表示の向きを設定
        self.cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        
        self.cameraPreviewLayer?.frame = view.frame
        self.view.layer.insertSublayer(self.cameraPreviewLayer!, at: 0)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection)
    {
//        print("test")
        //同期処理（非同期処理ではキューが溜まりすぎて画面がついていかない）
        DispatchQueue.main.sync(execute: {
            if (self.rectX < Int(self.view.frame.width)) {
                rectX = rectX + 5
            } else {
                rectX = 0
            }
            if (self.rectY < Int(self.view.frame.height)) {
                rectY = rectY + 5
            } else {
                rectY = 0
            }
            var faceRect : CGRect = CGRect(x: rectX, y: rectY, width: 100, height: 100)
            self.rectView.frame = faceRect
            
        })

    }
}
