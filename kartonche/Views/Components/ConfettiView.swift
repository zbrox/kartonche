//
//  ConfettiView.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import SwiftUI

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let color: Color
    let size: CGFloat
    let shape: ConfettiShape
    
    // Physics
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var angle: Double
    var angularVelocity: Double
    var wobblePhase: Double
    var wobbleSpeed: Double
    
    enum ConfettiShape {
        case rectangle, circle, triangle
    }
}

struct ConfettiView: View {
    @Binding var isActive: Bool
    
    @State private var pieces: [ConfettiPiece] = []
    @State private var startTime: Date?
    @State private var lastUpdateTime: Date?
    
    private let colors: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink, .mint, .cyan
    ]
    
    // Physics constants (per-second values)
    private let gravity: CGFloat = 600
    private let horizontalDrag: CGFloat = 3.0    // Higher = more drag
    private let verticalDrag: CGFloat = 0.3
    private let rotationDrag: CGFloat = 1.2
    private let wobbleAmount: CGFloat = 100
    private let duration: TimeInterval = 4.0
    
    var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    for piece in pieces {
                        context.drawLayer { ctx in
                            ctx.translateBy(x: piece.x, y: piece.y)
                            ctx.rotate(by: .degrees(piece.angle))
                            
                            let rect = CGRect(
                                x: -piece.size / 2,
                                y: -piece.size / 2,
                                width: piece.size,
                                height: piece.size * 1.5
                            )
                            
                            switch piece.shape {
                            case .rectangle:
                                ctx.fill(Path(rect), with: .color(piece.color))
                            case .circle:
                                ctx.fill(Path(ellipseIn: rect), with: .color(piece.color))
                            case .triangle:
                                var path = Path()
                                path.move(to: CGPoint(x: 0, y: -piece.size / 2))
                                path.addLine(to: CGPoint(x: piece.size / 2, y: piece.size / 2))
                                path.addLine(to: CGPoint(x: -piece.size / 2, y: piece.size / 2))
                                path.closeSubpath()
                                ctx.fill(path, with: .color(piece.color))
                            }
                        }
                    }
                }
                .onChange(of: timeline.date) { oldDate, newDate in
                    guard isActive, let start = startTime else { return }
                    
                    let elapsed = newDate.timeIntervalSince(start)
                    if elapsed > duration {
                        stopConfetti()
                        return
                    }
                    
                    let dt = lastUpdateTime.map { newDate.timeIntervalSince($0) } ?? 0
                    lastUpdateTime = newDate
                    
                    if dt > 0 && dt < 0.1 { // Sanity check - skip huge deltas
                        updatePhysics(dt: dt, elapsed: elapsed, screenHeight: geometry.size.height)
                    }
                }
            }
            .onChange(of: isActive) { _, newValue in
                if newValue && pieces.isEmpty {
                    startConfetti(in: geometry.size)
                } else if !newValue {
                    stopConfetti()
                }
            }
            .onAppear {
                if isActive && pieces.isEmpty {
                    startConfetti(in: geometry.size)
                }
            }
        }
        .allowsHitTesting(false)
    }
    
    private func startConfetti(in size: CGSize) {
        let centerX = size.width / 2
        let startY = size.height * 0.4
        
        pieces = (0..<80).map { _ in
            let angle = Double.random(in: -Double.pi * 0.8 ... -Double.pi * 0.2)
            let speed = Double.random(in: 400...900)
            
            return ConfettiPiece(
                color: colors.randomElement()!,
                size: CGFloat.random(in: 8...14),
                shape: [.rectangle, .rectangle, .circle, .triangle].randomElement()!,
                x: centerX + CGFloat.random(in: -20...20),
                y: startY,
                vx: CGFloat(cos(angle) * speed),
                vy: CGFloat(sin(angle) * speed),
                angle: Double.random(in: 0...360),
                angularVelocity: Double.random(in: -400...400),
                wobblePhase: Double.random(in: 0...Double.pi * 2),
                wobbleSpeed: Double.random(in: 8...15)
            )
        }
        
        startTime = Date()
        lastUpdateTime = Date()
    }
    
    private func stopConfetti() {
        pieces = []
        startTime = nil
        lastUpdateTime = nil
        isActive = false
    }
    
    private func updatePhysics(dt: Double, elapsed: Double, screenHeight: CGFloat) {
        let dtCG = CGFloat(dt)
        
        for i in pieces.indices {
            // Gravity
            pieces[i].vy += gravity * dtCG
            
            // Air resistance (exponential decay: v *= e^(-drag * dt))
            pieces[i].vx *= exp(-horizontalDrag * dtCG)
            pieces[i].vy *= exp(-verticalDrag * dtCG)
            
            // Wobble
            let wobble = sin(elapsed * pieces[i].wobbleSpeed + pieces[i].wobblePhase) * wobbleAmount * dtCG
            pieces[i].x += wobble
            
            // Position
            pieces[i].x += pieces[i].vx * dtCG
            pieces[i].y += pieces[i].vy * dtCG
            
            // Rotation
            pieces[i].angle += pieces[i].angularVelocity * dt
            pieces[i].angularVelocity *= exp(-rotationDrag * dt)
        }
    }
}

struct ConfettiModifier: ViewModifier {
    @Binding var isActive: Bool
    
    func body(content: Content) -> some View {
        content.overlay {
            ConfettiView(isActive: $isActive)
        }
    }
}

extension View {
    func confetti(isActive: Binding<Bool>) -> some View {
        modifier(ConfettiModifier(isActive: isActive))
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var showConfetti = false
        
        var body: some View {
            VStack {
                Spacer()
                Button("Celebrate!") {
                    showConfetti = true
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .confetti(isActive: $showConfetti)
        }
    }
    
    return PreviewWrapper()
}
