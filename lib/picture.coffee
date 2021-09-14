if Meteor.isClient
    Router.route '/pictures', (->
        @render 'pictures'
        ), name:'pictures
        '

    Template.pictures.onCreated ->
        Session.setDefault('image_sort','views')
        @autorun -> Meteor.subscribe 'image',
            Session.get('image_title_filter')
            Session.get('image_view_filter')
            Session.get('image_sort')
            Session.get('image_sort_direction')
            
        # @autorun -> Meteor.subscribe 'model_docs', 'image', 20
        # @autorun -> Meteor.subscribe 'model_docs', 'thing', 100

    Template.pictures.helpers
        image_docs: ->
            match = {model:'image'}
            # if Session.get('image_status_filter')
            #     match.status = Session.get('image_status_filter')
            # if Session.get('image_delivery_filter')
            #     match.delivery_method = Session.get('image_sort_filter')
            # if Session.get('image_sort_filter')
            #     match.delivery_method = Session.get('order_sort_filter')
            Docs.find match,
                sort: 
                    "#{Session.get('image_sort')}":Session.get('image_sort_direction')

    Template.pictures.events
        'click .add_image': ->
            new_id = 
                Docs.insert 
                    model:'image'
                    _author_id:Meteor.userId()
                    _author_username:Meteor.user().username
                    _timestamp:Date.now()

            Router.go "/image/#{new_id}/edit"
            

if Meteor.isClient
    Router.route '/image/:doc_id', (->
        @layout 'layout'
        @render 'image_view'
        ), name:'image_view'

    Template.image_view.onRendered ->
        Meteor.call 'log_view', Router.current().params.doc_id, ->
    Template.image_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
    Template.image_view.events
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
      
        'click .delete_image': ->
            thing_count = Docs.find(model:'thing').count()
            if confirm "delete? #{thing_count} things still"
                Docs.remove @_id
                Router.go "/image"
    
        'click .mark_ready': ->
            if confirm 'mark ready?'
                Docs.insert 
                    model:'image_event'
                    image_id: Router.current().params.doc_id
                    image_status:'ready'

        'click .add_review': ->
            Docs.insert 
                model:'image_review'
                image_id: Router.current().params.doc_id
                
                
        'click .review_positive': ->
            Docs.update @_id,
                $set:
                    rating:1
        'click .review_negative': ->
            Docs.update @_id,
                $set:
                    rating:-1

        'click .order_image': ->
            image = Docs.findOne Router.current().params.doc_id
            new_order_id = 
                Docs.insert 
                    model:'order'
                    parent_id:image._id
                    image_id:image._id
                    purchase_amount:image.price_dollars*100
                    image_title:image.title
            Router.go "/order/#{new_order_id}/edit"


    Template.image_view.helpers
        image_review: ->
            Docs.findOne 
                model:'image_review'
                image_id:Router.current().params.doc_id
    
        can_image: ->
            # if StripeCheckout
            unless @_author_id is Meteor.userId()
                image_count =
                    Docs.find(
                        model:'image'
                        image_id:@_id
                    ).count()
                if image_count is @servings_amount
                    false
                else
                    true
            # else
            #     false




if Meteor.isServer
    Meteor.publish 'pictures', (
        title_filter
        section
        sort_key
        sort_direction=-1
        )->
        # image = Docs.findOne image_id
        match = {model:'image'}
        # match.app = 'bc'
        if section 
            match.section = section
        if title_filter and title_filter.length > 1
            match.title = {$regex:title_filter, $options:'i'}

        Docs.find match,
            sort:"#{sort_key}":sort_direction
            limit:42
        


# if Meteor.isClient
#     Template.user_shop_item.onCreated ->
#         # @autorun => Meteor.subscribe 'image_from_shop_id', @data._id
#     Template.user_shop.onCreated ->
#         @autorun => Meteor.subscribe 'user_shop', Router.current().params.username
#         @autorun => Meteor.subscribe 'model_docs', 'image'
#     Template.user_shop.helpers
#         shop: ->
#             current_user = Meteor.users.findOne username:Router.current().params.username
#             Docs.find {
#                 model:'shop'
#             }, sort:_timestamp:-1



if Meteor.isClient
    Router.route '/picture/:doc_id/edit', (->
        @layout 'layout'
        @render 'picture_edit'
        ), name:'picture_edit'



    Template.picture_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'source'

    Template.picture_edit.onRendered ->
        # Meteor.setTimeout ->
        #     today = new Date()
        #     $('#availability')
        #         .calendar({
        #             inline:true
        #             # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
        #             # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
        #         })
        # , 2000

    Template.picture_edit.helpers
    Template.picture_edit.events
        'click .delete_shop': ->
            if confirm "delete #{@title}?"
                Docs.remove @_id
                Router.go "/shop"


    # Template.linked_image.onCreated ->
    #     # console.log @data
    #     @autorun => Meteor.subscribe 'doc_by_id', @data.image_id, ->

    # Template.linked_image.helpers
    #     linked_image_doc: ->
    #         console.log @
    #         Docs.findOne @image_id
            