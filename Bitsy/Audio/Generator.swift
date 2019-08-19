//
//  Generator.swift
//  Bitsy
//
//  Created by sphota on 8/14/19.
//  Copyright © 2019 alevkov. All rights reserved.
//

import Foundation
import AVFoundation
import CoreAudio
import AudioToolbox

enum GeneratorType {
  case square
  case sine
}

class Generator {
  public var sampleRate: Float
  public var frequency : Float
  public var amplitude : Float
  public var counter   : Float
  
  public init(sampleRate: Float) {
    self.amplitude = 0.0
    self.frequency = 0.0
    self.sampleRate = sampleRate
    self.counter = 0.0
  }
  
  public func render(bufferList: UnsafeMutableAudioBufferListPointer?) {
    print("render(buffer: UnsafeMutableAudioBufferListPointer?) -- STUB!")
  }
  
  fileprivate func parseBufferList(bufferList: UnsafeMutableAudioBufferListPointer?) -> (UnsafeMutablePointer<Float>?, Int) {
    guard let bufferList = bufferList else {
      DLog(message: "error: no AudioBufferList")
      return (nil, -1)
    }
    guard let channelBuffer = bufferList[0].mData else {
      DLog(message: "error: no AudioBuffer for channel")
      return (nil, -1)
    }
    
    let nframes = Int(bufferList[0].mDataByteSize) / MemoryLayout<Float>.size
    let ptr = channelBuffer.assumingMemoryBound(to: Float.self)
    
    return (ptr, nframes)
  }
}

class SquareWaveGenerator: Generator {
  
  public override func render(bufferList: UnsafeMutableAudioBufferListPointer?) {
    var (ptr, n) = parseBufferList(bufferList: bufferList)
    
    if n < 0 {
      DLog(message: "error: could not get audio buffer")
      return
    }
    
    let cycleLength = self.sampleRate / self.frequency
    let halfCycleLength = cycleLength / 2
    let amp = self.amplitude, minusAmp = -self.amplitude
    var j = self.counter
    
    for _ in 0 ..< n {
      if j < halfCycleLength {
        ptr?.pointee = Float(amp)
      }
      else {
        ptr?.pointee = Float(minusAmp)
      }
      ptr = ptr?.successor()
      j += 1.0
      if ( j > cycleLength) {
        j -= cycleLength
      }
    }
    self.counter = j
  }
}

class SineWaveGenerator: Generator {
  
  public override func render(bufferList: UnsafeMutableAudioBufferListPointer?) {
    var (ptr, n) = parseBufferList(bufferList: bufferList)
    
    if n < 0 {
      DLog(message: "error: could not get audio buffer")
      return
    }
    
    var theta = self.counter
    let theta_increment = 2.0 * Float.pi * self.frequency / self.sampleRate;
    
    for _ in 0 ..< n {
      ptr?.pointee = Float(sin(theta)) * Float(self.amplitude)
      
      theta = theta + theta_increment
      if (theta > 2.0 * Float.pi) {
        theta = theta - (2.0 * Float.pi)
      }
      ptr = ptr?.successor()
    }
    self.counter = theta
  }
}
