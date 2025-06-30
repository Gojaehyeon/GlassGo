import SwiftUI

// NSViewRepresentable로 드래그 지원 커스텀 뷰
class DraggableHostingView<Content: View>: NSHostingView<Content> {
    override func mouseDown(with event: NSEvent) {
        self.window?.performDrag(with: event)
    }
}

struct DraggableRepresentable<Content: View>: NSViewRepresentable {
    let content: Content
    func makeNSView(context: Context) -> DraggableHostingView<Content> {
        DraggableHostingView(rootView: content)
    }
    func updateNSView(_ nsView: DraggableHostingView<Content>, context: Context) {
        nsView.rootView = content
    }
}

struct MiniGlassPopover: View {
    var body: some View {
        DraggableRepresentable(content:
            Group {
                if #available(macOS 26.0, *) {
                    GlassEffectContainer(spacing: 40.0) {
                        ZStack {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 250.0, height: 250.0)
                                .glassEffect()
                            Button("") {
                            }
                            .buttonStyle(.glass)

                        }
                    }
                } else {
                    Circle()
                        .fill(Color.clear)
                }
            }
        )
    }
}

#Preview {
    MiniGlassPopover()
} 
