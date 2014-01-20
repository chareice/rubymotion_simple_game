class MenuScene < Joybox::Core::Scene

    def on_enter
        menu_layer = MenuLayer.new

        self << menu_layer
    end

end