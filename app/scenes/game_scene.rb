class GameScene < Joybox::Core::Scene

    def on_enter
        game_layer = GameLayer.new

        self << game_layer
    end

end