//
//  MainView.swift
//  auto-clicker
//
//  Created by Ben Tindall on 27/03/2022.
//

import SwiftUI
import DateStrings

struct MainView: View {
    
    @EnvironmentObject var themeService: ThemeService
    
    @StateObject var autoClickSimulator: AutoClickSimulator = AutoClickSimulator()
    @StateObject var delayTimer: DelayTimer = DelayTimer()
    
    // Some weird behaviour on macOS 11.2.3 and Swift 5 causes the app to hang on launch with these published and being passed through to View Bindings
    // For some reason placing any of this in an observable object will insta-hang the app, it never crashes but also never launches. No idea why as its
    // near impossible to debug!
    @State private var pressInterval: Int = DEFAULT_PRESS_INTERVAL
    @State private var pressIntervalDuration: Duration = Duration.milliseconds
    
    @State private var pressKey: String = ""
    @State private var pressAmount: Int = DEFAULT_PRESS_AMOUNT
    
    @State private var startDelay: Int = DEFAULT_START_DELAY
//    @State private var repeatDelayDuration: Duration = Duration.seconds
    
    @State private var repeatAmount: Int = DEFAULT_REPEAT_AMOUNT
    
    var estNextClickAt: Date {
        .init(timeInterval: self.pressIntervalDuration.asTimeInterval(interval: self.pressInterval), since: .init())
    }
    
    var estFinalClickAt: Date {
        .init(timeInterval: self.pressIntervalDuration.asTimeInterval(interval: self.pressInterval * self.repeatAmount), since: .init())
    }

    // Stubbing methods to work around the weird hang issue
    func start() -> Void {
        self.delayTimer.start(delayInSeconds: self.startDelay,
                              onFinish: {
                                  self.autoClickSimulator.start(duration: self.pressIntervalDuration,
                                                                interval: self.pressInterval,
                                                                presses: self.pressAmount,
                                                                iterations: self.repeatAmount)
                              })
    }
    
    var body: some View {
        VStack {
            
            // MARK: - Action Stage
            
            VStack {
                ActionStageLine {
                    Text("Every")
                    
                    DynamicWidthNumberField(text: "",
                                            min: MIN_PRESS_INTERVAL,
                                            max: MAX_PRESS_INTERVAL,
                                            number: self.$pressInterval)
                        .disabled(self.autoClickSimulator.isAutoClicking || self.delayTimer.isCountingDown)
                    
                    DurationSelector(selectedDuration: self.$pressIntervalDuration)
                        .disabled(self.autoClickSimulator.isAutoClicking || self.delayTimer.isCountingDown)
                    
                    Text(",")
                }
                
                ActionStageLine {
                    Text("press")
                    
                    Button("Left Click") {
                        
                    }
                    .buttonStyle(UnderlinedButtonStyle())
                    .disabled(true) // This feature is part of another feature branch
//                    .disabled(self.autoClickSimulator.isAutoClicking || self.delayTimer.isCountingDown)
                    
//                    DynamicWidthNumberField(text: "",
//                                            min: MIN_CLICK_AMOUNT,
//                                            max: MAX_CLICK_AMOUNT,
//                                            number: (self.autoClickSimulator.isAutoClicking || self.delayTimer.isCountingDown
//                                                     ? self.$autoClickSimulator.remainingPressesThisAction
//                                                     : self.$clickAmount))
//                        .disabled(self.autoClickSimulator.isAutoClicking || self.delayTimer.isCountingDown)
                    
                    DynamicWidthNumberField(text: "",
                                            min: MIN_PRESS_AMOUNT,
                                            max: MAX_PRESS_AMOUNT,
                                            number: self.$pressAmount)
                        .disabled(self.autoClickSimulator.isAutoClicking || self.delayTimer.isCountingDown)
                    
                    Text("\(self.pressAmount == 1 ? "time" : "times"),")
                }
                
                ActionStageLine {
                    Text("repeat")
                    
//                    DynamicWidthNumberField(text: "",
//                                            min: MIN_REPEAT_AMOUNT,
//                                            max: MAX_REPEAT_AMOUNT,
//                                            number: (self.autoClickSimulator.isAutoClicking || self.delayTimer.isCountingDown
//                                                     ? self.$autoClickSimulator.remainingInterations
//                                                     : self.$repeatAmount))
//                        .disabled(self.autoClickSimulator.isAutoClicking || self.delayTimer.isCountingDown)
                    
                    DynamicWidthNumberField(text: "",
                                            min: MIN_REPEAT_AMOUNT,
                                            max: MAX_REPEAT_AMOUNT,
                                            number: self.$repeatAmount)
                        .disabled(self.autoClickSimulator.isAutoClicking || self.delayTimer.isCountingDown)
                    
                    Text("\(self.repeatAmount == 1 ? "time" : "times").")
                }
                
                ActionStageLine {
                    Text("Wait")
                    
                    DynamicWidthNumberField(text: "",
                                            min: MIN_START_DELAY,
                                            max: MAX_START_DELAY,
                                            number: self.$startDelay)
                        .disabled(self.autoClickSimulator.isAutoClicking || self.delayTimer.isCountingDown)
                    
                    
                    Text("\(self.startDelay == 1 ? "second" : "seconds") before starting.")
                    
//                    DurationSelector(selectedDuration: self.$repeatDelayDuration)
//                        .disabled(self.autoClickSimulator.isAutoClicking || self.delayTimer.isCountingDown)
                    
//                    Text(",")
                }
            }
            .padding(.top, 20)
            .padding(.leading, 20)
            .padding(.bottom, 20)
            
            // MARK: - Buttons
            
            HStack {
                Button(action: self.start) {
                    Text(self.delayTimer.startButtonText.uppercased()).kerning(1)
                }
                .disabled(self.autoClickSimulator.isAutoClicking || self.delayTimer.isCountingDown)
//                .keyboardShortcut("s", modifiers: [.command])
                .buttonStyle(
                    StopwatchButtonStyle()
                )

                Button(action: self.autoClickSimulator.stop) {
                    Text("stop".uppercased()).kerning(1)
                }
                .disabled(!self.autoClickSimulator.isAutoClicking)
//                .keyboardShortcut("x", modifiers: [.command])
                .buttonStyle(
                    StopwatchButtonStyle()
                )
                
                Spacer()
            }
            .padding(.leading, 20)
            
            // MARK: - Spacer
            
            Spacer()
            
            // MARK: - Stats
            
            VStack {
                HStack {
                    Spacer()
                    
                    StatBox(title: "Next press at",
                            value: self.autoClickSimulator.isAutoClicking || self.delayTimer.isCountingDown
                                   ? self.autoClickSimulator.nextClickAt.asString(inFormat: "yyyy-MM-dd HH:mm:ss.SSS")
                                   : self.estNextClickAt.asString(inFormat: "yyyy-MM-dd HH:mm:ss.SSS"))
                    
                    Spacer()
                    
                    StatBox(title: "Final press at",
                            value: self.autoClickSimulator.isAutoClicking || self.delayTimer.isCountingDown
                                   ? self.autoClickSimulator.finalClickAt.asString(inFormat: "yyyy-MM-dd HH:mm:ss.SSS")
                                   : self.estFinalClickAt.asString(inFormat: "yyyy-MM-dd HH:mm:ss.SSS"))
                
                    Spacer()
                }
                .padding(.top, 18)
                .padding(.bottom, 10)
                
                // MARK: - Pretty Text

                Text("with ♥️ by Othyn")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(self.themeService.active.backgroundColour.lighter)
                    .onTapGesture(perform: self.themeService.randomise)
                    .padding(.bottom, 12)
            }
            .background(self.themeService.active.backgroundColour.darker)
        }
    }
}

//struct ActionStageView_Previews: PreviewProvider {
//    static var previews: some View {
//        ActionStageView()
//            .frame(minWidth: WindowSize.width)
//            .frame(maxWidth: WindowSize.width)
//            .padding(10)
//    }
//}
