if Meteor.isClient
    Router.route '/products', (->
        @render 'products'
        ), name:'products
        '

    Template.products.onCreated ->
        Session.setDefault('product_sort','views')
        @autorun -> Meteor.subscribe 'product',
            Session.get('product_title_filter')
            Session.get('product_view_filter')
            Session.get('product_sort')
            Session.get('product_sort_direction')
            
        # @autorun -> Meteor.subscribe 'model_docs', 'product', 20
        # @autorun -> Meteor.subscribe 'model_docs', 'thing', 100

    Template.products.helpers
        product_docs: ->
            match = {model:'product'}
            # if Session.get('product_status_filter')
            #     match.status = Session.get('product_status_filter')
            # if Session.get('product_delivery_filter')
            #     match.delivery_method = Session.get('product_sort_filter')
            # if Session.get('product_sort_filter')
            #     match.delivery_method = Session.get('order_sort_filter')
            Docs.find match,
                sort: 
                    "#{Session.get('product_sort')}":Session.get('product_sort_direction')

    Template.products.events
        'click .add_product': ->
            new_id = 
                Docs.insert 
                    model:'product'
                    _author_id:Meteor.userId()
                    _author_username:Meteor.user().username
                    _timestamp:Date.now()

            Router.go "/product/#{new_id}/edit"
            

if Meteor.isClient
    Router.route '/product/:doc_id', (->
        @layout 'layout'
        @render 'product_view'
        ), name:'product_view'

    Template.product_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    Template.product_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
    Template.product_view.events
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
      
        'click .delete_product': ->
            thing_count = Docs.find(model:'thing').count()
            if confirm "delete? #{thing_count} things still"
                Docs.remove @_id
                Router.go "/product"
    
        'click .mark_ready': ->
            if confirm 'mark ready?'
                Docs.insert 
                    model:'product_event'
                    product_id: Router.current().params.doc_id
                    product_status:'ready'

        'click .add_review': ->
            Docs.insert 
                model:'product_review'
                product_id: Router.current().params.doc_id
                
                
        'click .review_positive': ->
            Docs.update @_id,
                $set:
                    rating:1
        'click .review_negative': ->
            Docs.update @_id,
                $set:
                    rating:-1

        'click .order_product': ->
            product = Docs.findOne Router.current().params.doc_id
            new_order_id = 
                Docs.insert 
                    model:'order'
                    parent_id:product._id
                    product_id:product._id
                    purchase_amount:product.price_dollars*100
                    product_title:product.title
            Router.go "/order/#{new_order_id}/edit"


    Template.product_view.helpers
        product_review: ->
            Docs.findOne 
                model:'product_review'
                product_id:Router.current().params.doc_id
    
        can_product: ->
            # if StripeCheckout
            unless @_author_id is Meteor.userId()
                product_count =
                    Docs.find(
                        model:'product'
                        product_id:@_id
                    ).count()
                if product_count is @servings_amount
                    false
                else
                    true
            # else
            #     false




if Meteor.isServer
    Meteor.publish 'product', (
        title_filter
        section
        sort_key
        sort_direction=-1
        )->
        # product = Docs.findOne product_id
        match = {model:'product'}
        # match.app = 'bc'
        if section 
            match.section = section
        if title_filter and title_filter.length > 1
            match.title = {$regex:title_filter, $options:'i'}

        Docs.find match,
            sort:"#{sort_key}":sort_direction
            limit:42
        
    Meteor.publish 'review_from_product_id', (product_id)->
        # product = Docs.findOne product_id
        # match = {model:'product'}
        Docs.find 
            model:'product_review'
            shop_id:shop_id
        
    Meteor.publish 'product_by_shop_id', (shop_id)->
        shop = Docs.findOne shop_id
        Docs.find
            _id: shop.product_id
    Meteor.publish 'shop_things', (shop_id)->
        shop = Docs.findOne shop_id
        Docs.find
            model:'thing'
            shop_id: shop_id

    # Meteor.methods
        # shop_shop: (shop_id)->
        #     shop = Docs.findOne shop_id
        #     Docs.insert
        #         model:'shop'
        #         shop_id: shop._id
        #         shop_price: shop.price_per_serving
        #         buyer_id: Meteor.userId()
        #     Meteor.users.update Meteor.userId(),
        #         $inc:credit:-shop.price_per_serving
        #     Meteor.users.update shop._author_id,
        #         $inc:credit:shop.price_per_serving
        #     Meteor.call 'calc_shop_data', shop_id, ->



# if Meteor.isClient
#     Template.user_shop_item.onCreated ->
#         # @autorun => Meteor.subscribe 'product_from_shop_id', @data._id
#     Template.user_shop.onCreated ->
#         @autorun => Meteor.subscribe 'user_shop', Router.current().params.username
#         @autorun => Meteor.subscribe 'model_docs', 'product'
#     Template.user_shop.helpers
#         shop: ->
#             current_user = Meteor.users.findOne username:Router.current().params.username
#             Docs.find {
#                 model:'shop'
#             }, sort:_timestamp:-1

if Meteor.isServer
    # Meteor.publish 'user_shop', (username)->
    #     # user = Meteor.users.findOne username:username
    #     Docs.find 
    #         model:'shop'
    #         _author_username:username
            
    
    Meteor.publish 'user_shop', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'shop'
            _author_id: user._id
        }, 
            limit:42
            sort:_timestamp:-1
            
    Meteor.publish 'product_from_shop_id', (shop_id)->
        shop = Docs.findOne shop_id
        Docs.find
            model:'product'
            _id: shop.product_id


if Meteor.isClient
    Router.route '/product/:doc_id/edit', (->
        @layout 'layout'
        @render 'product_edit'
        ), name:'product_edit'



    Template.product_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'source'

    Template.product_edit.onRendered ->
        # Meteor.setTimeout ->
        #     today = new Date()
        #     $('#availability')
        #         .calendar({
        #             inline:true
        #             # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
        #             # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
        #         })
        # , 2000

    Template.product_edit.helpers
        balance_after_purchase: ->
            Meteor.user().points - @purchase_amount
        percent_difference: ->
            balance_after_purchase = 
                Meteor.user().points - @purchase_amount
            # difference
            @purchase_amount/Meteor.user().points
    Template.product_edit.events
        'click .complete_shop': (e,t)->
            console.log @
            Session.set('shoping',true)
            if @purchase_amount
                if Meteor.user().points and @purchase_amount < Meteor.user().points
                    Meteor.call 'complete_shop', @_id, =>
                        Router.go "/product/#{@product_id}"
                        Session.set('shoping',false)
                else 
                    alert "not enough points"
                    Router.go "/user/#{Meteor.user().username}/points"
                    Session.set('shoping',false)
            else 
                alert 'no purchase amount'
            
            
        'click .delete_shop': ->
            if confirm "delete #{@title}?"
                Docs.remove @_id
                Router.go "/shop"


    # Template.linked_product.onCreated ->
    #     # console.log @data
    #     @autorun => Meteor.subscribe 'doc_by_id', @data.product_id, ->

    # Template.linked_product.helpers
    #     linked_product_doc: ->
    #         console.log @
    #         Docs.findOne @product_id
            
            
if Meteor.isServer
    Meteor.methods  
        complete_shop: (shop_id)->
            console.log 'completing shop', shop_id
            current_shop = Docs.findOne shop_id            
            Docs.update shop_id, 
                $set:
                    status:'purchased'
                    purchased:true
                    purchase_timestamp: Date.now()
            console.log 'marked complete'
            Meteor.call 'calc_user_points', @_author_id, ->