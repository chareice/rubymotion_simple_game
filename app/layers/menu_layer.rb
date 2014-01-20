class MenuLayer < Joybox::Core::Layer
    def on_enter
        layer_color = LayerColor.new color: "ffffff".to_color
        layer_color.position = [0, 0]
        on_touches_began do |touches, event|
            p touches
        end
        self.add_child layer_color
    end
end
