class GameLayer < Joybox::Core::Layer
    def on_enter
        backgroundColor = LayerColor.new color: "ffffff".to_color
        player = Sprite.new file_name: 'sprites/player.png', rect: [[0, 0], [27, 40]]
        player.position = [player.contentSize.width / 2, 160 ]
        self << backgroundColor
        self << player
        @maxTarget = 10
        @targets ||= Array.new
        @projectiles ||= Array.new
        self.schedule('addTarget', interval:1.0)
        self.schedule('motion_crash')
        on_touches_ended do |touches, event|
            touch = touches.any_object
            #p "touch location x:#{touch.location.x} y:#{touch.location.y}"
            location = Joybox.director.convertToGL touch.location
            addProjectile(location)
        end
    end

    private
    def motion_crash
        @projectiles.each do |projectile|
            @targets.each do |target|
                if CGRectIntersectsRect(projectile.bounding_box, target.bounding_box)
                    remove_target(target)
                    remove_projectile(projectile)
                end
            end
        end
    end
    def addProjectile(location)
        location.y = Screen.height-location.y
        def get_k(a, b)
            (b.y - a.y) / (b.x - a.x)
        end
        projectile = Sprite.new file_name: 'sprites/projectile.png', rect: [[0, 0], [20, 20]]
        projectile.position = [20, Screen.height/2]
        top_corner_k = get_k(projectile.position, CGPointMake(Screen.width, Screen.height))
        bottom_corner_k = get_k(projectile.position, CGPointMake(Screen.width, 0))
        k = get_k(projectile.position, location)
        self << projectile
        @projectiles << projectile
        case
        when k > top_corner_k
            #已知Y
            y = Screen.height
            x = (y - projectile.position.y) / k + projectile.position.x
        when k == top_corner_k
            #已知 X, Y
            x = Screen.width
            y = Screen.height
        when ((k < top_corner_k) and (k > bottom_corner_k))
            #已知 X
            x = Screen.width
            y = k * (x - projectile.position.x) + projectile.position.y
        when k == bottom_corner_k
            #已知 X, Y
            x = Screen.width
            y = 0
        when k < bottom_corner_k
            #已知 Y
            y = 0
            x = (y - projectile.position.y) / k + projectile.position.x
        end
        length = Math.sqrt((((y - projectile.position.y) ** 2) + ((x - projectile.position.x) ** 2)))
        velocity = 480/1
        duration = length / velocity
        move_action = Move.to position:[x, y], duration: duration
        callback_action = Callback.with do |projectile|
            remove_projectile(projectile)
        end
        projectile.run_action Sequence.with actions:[move_action, callback_action]
    end

    def addTarget
        if @targets.size < @maxTarget
            makeTarget
        end
    end
    def makeTarget
        target = Sprite.new file_name: 'sprites/target.png', rect: [[0, 0], [27, 40]]
        miny = target.contentSize.height / 2
        maxy = Screen.height - miny
        rangey = maxy - miny
        y = rand(rangey + 1) + miny
        target.position = [Screen.width - target.contentSize.width / 2, y]
        self << target
        @targets << target
        move_action = Move.to position:[-target.contentSize.width/2, y], duration: 5.0

        callback_action = Callback.with do |target| 
            remove_target(target)
        end
        target.run_action Sequence.with actions:[move_action,callback_action]
    end

    def remove_projectile(projectile)
        self.removeChild(projectile, cleanup:true)
        @projectiles.delete(projectile)
    end

    def remove_target(target)
        self.removeChild(target, cleanup: true)
        @targets.delete target
    end
end
