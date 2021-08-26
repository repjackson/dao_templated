# if Meteor.isClient
#     # Template.user_dashboard.onCreated ->
#     #     @autorun => Meteor.subscribe 'user_upcoming_reservations', Router.current().params.username
#     # Template.user_dashboard.onCreated ->
#         # @autorun => Meteor.subscribe 'user_upcoming_reservations', Router.current().params.username
#         # # @autorun => Meteor.subscribe 'user_handling', Router.current().params.username
#         # @autorun => Meteor.subscribe 'user_current_reservations', Router.current().params.username
#     # Template.user_dashboard.helpers
#         # current_reservations: ->
#         #     Docs.find
#         #         model:'reservation'
#         #         user_username:Router.current().params.username
#         # upcoming_reservations: ->
#         #     Docs.find
#         #         model:'reservation'
#         #         user_username:Router.current().params.username
#         # current_handling_rentals: ->
#         #     current_user = Meteor.users.findOne username:Router.current().params.username
#         #     Docs.find
#         #         model:'rental'
#         #         handler_username:current_user.username
#         # current_interest_rate: ->
#         #     interest_rate = 0
#         #     if Meteor.user().handling_active
#         #         current_user = Meteor.users.findOne username:Router.current().params.username
#         #         handling_rentals = Docs.find(
#         #             model:'rental'
#         #             handler_username:current_user.username
#         #         ).fetch()
#         #         for handling in handling_rentals
#         #             interest_rate += handling.hourly_dollars*.1
#         #     interest_rate.toFixed(2)


#     # Template.group_roles.helpers
#     #     user_role_docs: ->
#     #         Docs.find 
#     #             model:'role'
#     #             group_id: Router.current().params.doc_id
                
                
#     # Template.user_dashboard.events
#     #     'click .recalc_wage_stats': (e,t)->
#     #         Meteor.call 'recalc_wage_stats', Router.current().params.username


#     # Template.user_chat.helpers
#     #     chat_messages: ->
#     #         Docs.find 
#     #             model:'chat_message'

#     # Template.user_chat.events
#     #     'keyup .add_chat': (e,t)->
#     #         if e.which is 13
#     #             # parent = Docs.findOne Router.current().params.doc_id
#     #             body = t.$('.add_chat').val()
#     #             Docs.insert
#     #                 model:'chat_message'
#     #                 body:body
#     #             t.$('.add_chat').val('')
#     # Template.user_chat.onCreated ->
#     #     @autorun => Meteor.subscribe 'user_chat', Router.current().params.username


if Meteor.isClient
    Router.route '/user/:username/food', (->
        @layout 'profile_layout'
        @render 'user_food'
        ), name:'user_food'
    
    Template.user_food.onCreated ->
        @autorun => Meteor.subscribe 'docs', picked_tags.array(), 'thought'


    Template.user_food.onCreated ->
        # @autorun => Meteor.subscribe 'user_food', Router.current().params.username
        @autorun => Meteor.subscribe 'user_model_docs', 'food_order', Router.current().params.username

    Template.user_food.events
        'keyup .new_public_message': (e,t)->
            if e.which is 13
                val = $('.new_public_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:false
                    target_user_id: target_user._id
                val = $('.new_public_message').val('')

        'click .submit_public_message': (e,t)->
            val = $('.new_public_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                is_private:false
                body: val
                target_user_id: target_user._id
            val = $('.new_public_message').val('')


        'keyup .new_private_message': (e,t)->
            if e.which is 13
                val = $('.new_private_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:true
                    target_user_id: target_user._id
                val = $('.new_private_message').val('')

        'click .submit_private_message': (e,t)->
            val = $('.new_private_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                body: val
                is_private:true
                target_user_id: target_user._id
            val = $('.new_private_message').val('')



    Template.user_food.helpers
        food_orders: ->
            user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'food_order'
                # _author_id:user._id



if Meteor.isServer
    Meteor.publish 'user_public_food', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:false

    Meteor.publish 'user_private_food', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:true
            _author_id:Meteor.userId()

if Meteor.isClient
    Router.route '/user/:username/delivery', (->
        @layout 'profile_layout'
        @render 'user_delivery'
        ), name:'user_delivery'
    
    Template.user_delivery.onCreated ->
        @autorun => Meteor.subscribe 'docs', picked_tags.array(), 'thought'


    Template.user_delivery.onCreated ->
        @autorun => Meteor.subscribe 'user_delivery', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'message'

    Template.user_delivery.events
        'keyup .new_public_message': (e,t)->
            if e.which is 13
                val = $('.new_public_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:false
                    target_user_id: target_user._id
                val = $('.new_public_message').val('')

        'click .submit_public_message': (e,t)->
            val = $('.new_public_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                is_private:false
                body: val
                target_user_id: target_user._id
            val = $('.new_public_message').val('')


        'keyup .new_private_message': (e,t)->
            if e.which is 13
                val = $('.new_private_message').val()
                console.log val
                target_user = Meteor.users.findOne(username:Router.current().params.username)
                Docs.insert
                    model:'message'
                    body: val
                    is_private:true
                    target_user_id: target_user._id
                val = $('.new_private_message').val('')

        'click .submit_private_message': (e,t)->
            val = $('.new_private_message').val()
            console.log val
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.insert
                model:'message'
                body: val
                is_private:true
                target_user_id: target_user._id
            val = $('.new_private_message').val('')



    Template.user_delivery.helpers
        user_public_delivery: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'message'
                target_user_id: target_user._id
                is_private:false

        user_private_delivery: ->
            target_user = Meteor.users.findOne(username:Router.current().params.username)
            Docs.find
                model:'message'
                target_user_id: target_user._id
                is_private:true
                _author_id:Meteor.userId()



if Meteor.isServer
    Meteor.publish 'user_public_delivery', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:false

    Meteor.publish 'user_private_delivery', (username)->
        target_user = Meteor.users.findOne(username:Router.current().params.username)
        Docs.find
            model:'message'
            target_user_id: target_user._id
            is_private:true
            _author_id:Meteor.userId()

if Meteor.isClient
    Router.route '/user/:username/friends', (->
        @layout 'profile_layout'
        @render 'user_friends'
        ), name:'user_friends'
    
    Template.user_friends.onCreated ->
        @autorun => Meteor.subscribe 'users'



    Template.user_friends.helpers
        friends: ->
            current_user = Meteor.users.findOne Router.current().params.user_id
            Meteor.users.find
                _id:$in: current_user.friend_ids
        nonfriends: ->
            Meteor.users.find
                _id:$nin:Meteor.user().friend_ids


    # Template.user_friend_button.helpers
    #     is_friend: ->
    #         Meteor.user() and Meteor.user().friend_ids and @_id in Meteor.user().friend_ids


    # Template.user_friend_button.events
    #     'click .friend':->
    #         Meteor.users.update Meteor.userId(),
    #             $addToSet: friend_ids:@_id
    #     'click .unfriend':->
    #         Meteor.users.update Meteor.userId(),
    #             $pull: friend_ids:@_id

    #     'keyup .assign_earn': (e,t)->
    #         if e.which is 13
    #             post = t.$('.assign_earn').val().trim()
    #             # console.log post
    #             current_user = Meteor.users.findOne Router.current().params.user_id
    #             Docs.insert
    #                 body:post
    #                 model:'earn'
    #                 assigned_user_id:current_user._id
    #                 assigned_username:current_user.username

    #             t.$('.assign_earn').val('')



if Meteor.isClient
    Router.route '/user/:username/credits', (->
        @layout 'profile_layout'
        @render 'user_credits'
        ), name:'user_credits'


    Template.user_credits.onCreated ->
        @autorun => Meteor.subscribe 'user_credits', Router.current().params.username
        # @autorun => Meteor.subscribe 'model_docs', 'debit'

    Template.user_credits.events
        # 'keyup .new_credit': (e,t)->
        #     if e.which is 13
        #         val = $('.new_credit').val()
        #         console.log val
        #         target_user = Meteor.users.findOne(username:Router.current().params.username)
        #         Docs.insert
        #             model:'credit'
        #             body: val
        #             recipient_id: target_user._id



    Template.user_credits_small.helpers
        user_credits: ->
            target_user = Meteor.users.findOne({username:Router.current().params.username})
            Docs.find {
                model:'debit'
                recipient_id: target_user._id
            },
                sort:_timestamp:-1

    Template.user_credits.helpers
        user_credits: ->
            target_user = Meteor.users.findOne({username:Router.current().params.username})
            Docs.find {
                model:'debit'
                recipient_id: target_user._id
            },
                sort:_timestamp:-1




if Meteor.isServer
    Meteor.publish 'user_credits', (username)->
        user = Meteor.users.findOne username:username
        Docs.find
            model:'debit'
            recipient_id:user._id
