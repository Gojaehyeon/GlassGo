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

@available(macOS 15.0, *)
struct MiniGlassPopover: View {
    var body: some View {
        DraggableRepresentable(content:
            GlassEffectContainer {
                Circle()
                    .frame(width: 270, height: 270)
                    .glassEffect()
            }
            .frame(width: 300, height: 300)
        )
    }
}

#Preview {
    if #available(macOS 15.0, *) {
        MiniGlassPopover()
    }
} 