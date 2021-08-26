if Meteor.isClient
    
    Template.rating.onRendered ->
        Meteor.setTimeout =>
            $('.ui.rating').rating(
                # icon: 'pizza slice',
                initialRating: 3,
                maxRating: 10
            )
        , 1000
                
# if Meteor.isClient
    # Router.route '/food', (->
    #     @render 'food'
    #     ), name:'food'

    # Template.food.onCreated ->
    #     Session.setDefault('food_sort','views')
    #     @autorun -> Meteor.subscribe 'food',
    #         Session.get('food_title_filter')
    #         Session.get('food_view_filter')
    #         Session.get('food_sort')
    #         Session.get('food_sort_direction')
            
    #     # @autorun -> Meteor.subscribe 'model_docs', 'product', 20
    #     # @autorun -> Meteor.subscribe 'model_docs', 'thing', 100

    # Template.food.helpers
    #     food_docs: ->
    #         match = {model:'food'}
    #         # if Session.get('food_status_filter')
    #         #     match.status = Session.get('food_status_filter')
    #         # if Session.get('food_delivery_filter')
    #         #     match.delivery_method = Session.get('food_sort_filter')
    #         # if Session.get('food_sort_filter')
    #         #     match.delivery_method = Session.get('order_sort_filter')
    #         Docs.find match,
    #             sort: 
    #                 "#{Session.get('food_sort')}":Session.get('food_sort_direction')

    # Template.food.events
    #     'click .add_food': ->
    #         new_id = 
    #             Docs.insert 
    #                 model:'food'
    #         Router.go "/food/#{new_id}/edit"
            

if Meteor.isClient
    Router.route '/food/:doc_id', (->
        @layout 'layout'
        @render 'food_view'
        ), name:'food_view'

    Template.food_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    Template.drink_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
    Template.food_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
    Template.food_view.events
        'click .mark_arrived': ->
            # if confirm 'mark arrived?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    arrived: true
                    arrived_timestamp: Date.now()
                    status: 'arrived' 
        
        'click .mark_delivering': ->
            # if confirm 'mark delivering?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    delivering: true
                    delivering_timestamp: Date.now()
                    status: 'delivering' 
      
        'click .mark_delivered': ->
            # if confirm 'mark delivered?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    delivered: true
                    delivered_timestamp: Date.now()
                    status: 'delivered' 
      
        'click .delete_food': ->
            thing_count = Docs.find(model:'thing').count()
            if confirm "delete? #{thing_count} things still"
                Docs.remove @_id
                Router.go "/food"
    
        'click .mark_ready': ->
            if confirm 'mark ready?'
                Docs.insert 
                    model:'food_event'
                    food_id: Router.current().params.doc_id
                    food_status:'ready'

        'click .add_review': ->
            Docs.insert 
                model:'food_review'
                food_id: Router.current().params.doc_id
                
                
        'click .review_positive': ->
            Docs.update @_id,
                $set:
                    rating:1
        'click .review_negative': ->
            Docs.update @_id,
                $set:
                    rating:-1

        'click .order_food': ->
            product = Docs.findOne Router.current().params.doc_id
            new_order_id = 
                Docs.insert 
                    model:'order'
                    parent_id:product._id
                    product_id:product._id
                    purchase_amount:product.price_dollars*100
                    product_title:product.title
            Router.go "/order/#{new_order_id}/edit"


    Template.food_view.helpers
        food_review: ->
            Docs.findOne 
                model:'food_review'
                food_id:Router.current().params.doc_id
    
        can_food: ->
            # if StripeCheckout
            unless @_author_id is Meteor.userId()
                food_count =
                    Docs.find(
                        model:'food'
                        food_id:@_id
                    ).count()
                if food_count is @servings_amount
                    false
                else
                    true
            # else
            #     false




if Meteor.isServer
    Meteor.publish 'food', (
        title_filter
        section
        sort_key
        sort_direction=-1
        )->
        # food = Docs.findOne food_id
        match = {model:'food'}
        match.app = 'bc'
        if section 
            match.section = section
        if title_filter and title_filter.length > 1
            match.title = {$regex:title_filter, $options:'i'}

        Docs.find match,
            sort:"#{sort_key}":sort_direction
            limit:42
        
    Meteor.publish 'review_from_food_id', (food_id)->
        # food = Docs.findOne food_id
        # match = {model:'food'}
        Docs.find 
            model:'food_review'
            food_id:food_id
        
    Meteor.publish 'product_by_food_id', (food_id)->
        food = Docs.findOne food_id
        Docs.find
            _id: food.product_id
    Meteor.publish 'food_things', (food_id)->
        food = Docs.findOne food_id
        Docs.find
            model:'thing'
            food_id: food_id

    # Meteor.methods
        # food_food: (food_id)->
        #     food = Docs.findOne food_id
        #     Docs.insert
        #         model:'food'
        #         food_id: food._id
        #         food_price: food.price_per_serving
        #         buyer_id: Meteor.userId()
        #     Meteor.users.update Meteor.userId(),
        #         $inc:credit:-food.price_per_serving
        #     Meteor.users.update food._author_id,
        #         $inc:credit:food.price_per_serving
        #     Meteor.call 'calc_food_data', food_id, ->



# if Meteor.isClient
#     Template.user_food_item.onCreated ->
#         # @autorun => Meteor.subscribe 'product_from_food_id', @data._id
#     Template.user_food.onCreated ->
#         @autorun => Meteor.subscribe 'user_food', Router.current().params.username
#         @autorun => Meteor.subscribe 'model_docs', 'product'
#     Template.user_food.helpers
#         food: ->
#             current_user = Meteor.users.findOne username:Router.current().params.username
#             Docs.find {
#                 model:'food'
#             }, sort:_timestamp:-1

if Meteor.isServer
    # Meteor.publish 'user_food', (username)->
    #     # user = Meteor.users.findOne username:username
    #     Docs.find 
    #         model:'food'
    #         _author_username:username
            
    
    Meteor.publish 'user_food', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'food'
            _author_id: user._id
        }, 
            limit:42
            sort:_timestamp:-1
            
    Meteor.publish 'product_from_food_id', (food_id)->
        food = Docs.findOne food_id
        Docs.find
            model:'product'
            _id: food.product_id


if Meteor.isClient
    Router.route '/food/:doc_id/edit', (->
        @layout 'layout'
        @render 'food_edit'
        ), name:'food_edit'
    Router.route '/drink/:doc_id/edit', (->
        @layout 'layout'
        @render 'drink_edit'
        ), name:'drink_edit'



    Template.food_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'source'

    Template.food_edit.onRendered ->
        # Meteor.setTimeout ->
        #     today = new Date()
        #     $('#availability')
        #         .calendar({
        #             inline:true
        #             # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
        #             # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
        #         })
        # , 2000

    Template.food_edit.helpers
        balance_after_purchase: ->
            Meteor.user().points - @purchase_amount
        percent_difference: ->
            balance_after_purchase = 
                Meteor.user().points - @purchase_amount
            # difference
            @purchase_amount/Meteor.user().points
    Template.food_edit.events
        'click .complete_food': (e,t)->
            console.log @
            Session.set('fooding',true)
            if @purchase_amount
                if Meteor.user().points and @purchase_amount < Meteor.user().points
                    Meteor.call 'complete_food', @_id, =>
                        Router.go "/product/#{@product_id}"
                        Session.set('fooding',false)
                else 
                    alert "not enough points"
                    Router.go "/user/#{Meteor.user().username}/points"
                    Session.set('fooding',false)
            else 
                alert 'no purchase amount'
            
            
        'click .delete_food': ->
            if confirm "delete #{@title}?"
                Docs.remove @_id
                Router.go "/food"


    Template.linked_product.onCreated ->
        # console.log @data
        @autorun => Meteor.subscribe 'doc_by_id', @data.product_id, ->

    Template.linked_product.helpers
        linked_product_doc: ->
            console.log @
            Docs.findOne @product_id
            
            
if Meteor.isServer
    Meteor.methods  
        complete_food: (food_id)->
            console.log 'completing food', food_id
            current_food = Docs.findOne food_id            
            Docs.update food_id, 
                $set:
                    status:'purchased'
                    purchased:true
                    purchase_timestamp: Date.now()
            console.log 'marked complete'
            Meteor.call 'calc_user_points', @_author_id, ->