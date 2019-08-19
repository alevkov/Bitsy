//
//  Oscillator.swift
//  Bitsy
//
//  Created by sphota on 8/14/19.
//  Copyright © 2019 alevkov. All rights reserved.
//

import Foundation
import AVFoundation
import CoreAudio
import AudioToolbox

class Oscillator {
  
  private lazy var generator: Generator = Generator(sampleRate: 0) // stub
  private var ioUnit: AudioComponentInstance?
  private let midiOffset: Int = 60

  
  init(type: GeneratorType) {
    self.setWave(type: type)
    self.setUp()
    NotificationCenter.default.addObserver(self, selector: #selector(volumeDidChange(_:)), name: NSNotification.Name(rawValue: didChangeVolumeNotification), object: nil)
  }
  
  private func setUp() {
    let subType = kAudioUnitSubType_RemoteIO
    var ioUnitDesc = AudioComponentDescription(componentType: kAudioUnitType_Output,
                                               componentSubType: subType,
                                               componentManufacturer: kAudioUnitManufacturer_Apple,
                                               componentFlags: 0,
                                               componentFlagsMask: 0)

    guard let defaultOutput = AudioComponentFindNext(nil, &ioUnitDesc) else {
      DLog(message: "error: AudioComponentFindNext")
      return
    }
    var err = AudioComponentInstanceNew(defaultOutput, &self.ioUnit)
    
    guard err == 0 else {
      DLog(message: "error: AudioComponentInstanceNew")
      return
    }
    
    guard let ioUnitInitialized = ioUnit else {
      DLog(message: "error: AudioComponentInstanceNew")
      return
    }
    
    var input: AURenderCallbackStruct = AURenderCallbackStruct()
    input.inputProcRefCon = UnsafeMutableRawPointer(Unmanaged<Generator>.passRetained(self.generator).toOpaque())
    
    input.inputProc = {
      (inRefCon: UnsafeMutableRawPointer,
      ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
      inTimeStamp: UnsafePointer<AudioTimeStamp>,
      inBusNumber: UInt32,
      inNumberFrames: UInt32,
      ioData: UnsafeMutablePointer<AudioBufferList>?) -> OSStatus in
      
        let bufferList = UnsafeMutableAudioBufferListPointer(ioData)
        let generator = Unmanaged<Generator>.fromOpaque(inRefCon).takeRetainedValue()
        generator.render(bufferList: bufferList)
      
        let _ = Unmanaged<Generator>.fromOpaque(inRefCon).retain()
        return noErr
    }
    
    err = AudioUnitSetProperty(ioUnitInitialized,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               0,
                               &input,
                               UInt32(MemoryLayout<AURenderCallbackStruct>.size))
    
    let four_bytes_per_float: UInt32 = 4;
    let eight_bits_per_byte: UInt32 = 8;
    var streamFormat: AudioStreamBasicDescription = AudioStreamBasicDescription()
    streamFormat.mSampleRate = Double(generator.sampleRate);
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags =
      kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mBytesPerPacket = four_bytes_per_float;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = four_bytes_per_float;
    streamFormat.mChannelsPerFrame = 1;
    streamFormat.mBitsPerChannel = four_bytes_per_float * eight_bits_per_byte;
    
    err = AudioUnitSetProperty (ioUnitInitialized,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                0,
                                &streamFormat,
                                UInt32(MemoryLayout<AudioStreamBasicDescription>.size));
    
    AudioUnitInitialize(ioUnitInitialized)
  }
  
  public func start(note: Int) {
    guard let ioUnitInitialized = ioUnit else {
      print("error in AudioComponentInstanceNew()")
      return
    }
    self.generator.frequency = midiLookup[note + self.midiOffset] ?? 0.0
    AudioOutputUnitStart(ioUnitInitialized)
  }
  
  public func stop() {
    guard let ioUnitInitialized = ioUnit else {
      print("error in AudioComponentInstanceNew()")
      return
    }
    AudioOutputUnitStop(ioUnitInitialized)
  }
  
  public func setWave(type: GeneratorType) {
    switch type {
    case .sine:
      generator = SineWaveGenerator(sampleRate: 44100.0)
    case .square:
      generator = SquareWaveGenerator(sampleRate: 44100.0)
    }
    self.setUp()
  }
  
  @objc fileprivate func volumeDidChange(_ notification: Notification) {
    guard let value = notification.userInfo?["vol"] else {
      print("error in volumeDidChange(_:)")
      return
    }
    
    generator.amplitude = value as! Float
  }
}
