//
//  Constants.swift
//  Bitsy
//
//  Created by sphota on 8/16/19.
//  Copyright © 2019 alevkov. All rights reserved.
//

import Foundation

// Notifications
let didChangeVolumeNotification = "DidChangeVolume"

// Oscillator
public let midiLookup: Dictionary<Int, Float> = [60: 261.63,
                                                  61: 277.18,
                                                  62: 293.67,
                                                  63: 311.13,
                                                  64: 329.63,
                                                  65: 349.23,
                                                  66: 369.99,
                                                  67: 392.00,
                                                  68: 415.30,
                                                  69: 440.00,
                                                  70: 466.16,
                                                  71: 493.88,
                                                  72: 523.25,
                                                  73: 554.37,
                                                  74: 587.33,
                                                  75: 622.25,
                                                  76: 659.26,
                                                  77: 698.46,
                                                  78: 739.99,
                                                  79: 783.99,
                                                  80: 830.61,
                                                  81: 880.00,
                                                  82: 932.33,
                                                  83: 987.77]
