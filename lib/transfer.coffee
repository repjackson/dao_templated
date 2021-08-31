if Meteor.isClient
    Router.route '/transfers', (->
        @render 'transfers'
        ), name:'transfers'

    Template.transfers.onCreated ->
        @autorun -> Meteor.subscribe 'transfers',
            Session.get('transfer_status_filter')
        # @autorun -> Meteor.subscribe 'model_docs', 'product', 20
        # @autorun -> Meteor.subscribe 'model_docs', 'thing', 100

    Template.transfers.helpers
        transfer_docs: ->
            match = {model:'transfer'}
            if Session.get('transfer_status_filter')
                match.status = Session.get('transfer_status_filter')
            if Session.get('transfer_delivery_filter')
                match.delivery_method = Session.get('transfer_sort_filter')
            if Session.get('transfer_sort_filter')
                match.delivery_method = Session.get('transfer_sort_filter')
            Docs.find match,
                sort: _timestamp:-1


if Meteor.isClient
    Router.route '/transfer/:doc_id', (->
        @layout 'layout'
        @render 'transfer_view'
        ), name:'transfer_view'


    Template.transfer_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'product_by_transfer_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'transfer_things', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'review_from_transfer_id', Router.current().params.doc_id


    Template.transfer_view.events
        'click .mark_viewed': ->
            # if confirm 'mark viewed?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    runner_viewed: true
                    runner_viewed_timestamp: Date.now()
                    runner_username: Meteor.user().username
                    status: 'viewed' 
      
        'click .mark_preparing': ->
            # if confirm 'mark mark_preparing?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    preparing: true
                    preparing_timestamp: Date.now()
                    status: 'preparing' 
       
        'click .mark_prepared': ->
            # if confirm 'mark prepared?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    prepared: true
                    prepared_timestamp: Date.now()
                    status: 'prepared' 
     
        'click .mark_arrived': ->
            # if confirm 'mark arrived?'
            Docs.update Router.current().params.doc_id, 
                $set:
                    arrived: true
                    arrived_timestamp: Date.now()
                    status: 'arrived' 
    
        'click .mark_ready': ->
            if confirm 'mark ready?'
                Docs.insert 
                    model:'transfer_event'
                    transfer_id: Router.current().params.doc_id
                    transfer_status:'ready'

        'click .add_review': ->
            Docs.insert 
                model:'transfer_review'
                transfer_id: Router.current().params.doc_id
                
                
        'click .review_positive': ->
            Docs.update @_id,
                $set:
                    rating:1
        'click .review_negative': ->
            Docs.update @_id,
                $set:
                    rating:-1

    Template.transfer_view.helpers
        transfer_review: ->
            Docs.findOne 
                model:'transfer_review'
                transfer_id:Router.current().params.doc_id
    
        can_transfer: ->
            # if StripeCheckout
            unless @_author_id is Meteor.userId()
                transfer_count =
                    Docs.find(
                        model:'transfer'
                        transfer_id:@_id
                    ).count()
                if transfer_count is @servings_amount
                    false
                else
                    true
            # else
            #     false




if Meteor.isServer
    Meteor.publish 'transfers', (transfer_id, status)->
        # transfer = Docs.findOne transfer_id
        match = {model:'transfer', app:'bc'}
        if status 
            match.status = status

        Docs.find match, 
            limit:20
        
    # Meteor.publish 'review_from_transfer_id', (transfer_id)->
    #     # transfer = Docs.findOne transfer_id
    #     # match = {model:'transfer'}
    #     Docs.find 
    #         model:'transfer_review'
    #         transfer_id:transfer_id
        
    # Meteor.publish 'product_by_transfer_id', (transfer_id)->
    #     transfer = Docs.findOne transfer_id
    #     Docs.find
    #         _id: transfer.product_id
    # Meteor.publish 'transfer_things', (transfer_id)->
    #     transfer = Docs.findOne transfer_id
    #     Docs.find
    #         model:'thing'
    #         transfer_id: transfer_id

    # Meteor.methods
        # transfer_transfer: (transfer_id)->
        #     transfer = Docs.findOne transfer_id
        #     Docs.insert
        #         model:'transfer'
        #         transfer_id: transfer._id
        #         transfer_price: transfer.price_per_serving
        #         buyer_id: Meteor.userId()
        #     Meteor.users.update Meteor.userId(),
        #         $inc:credit:-transfer.price_per_serving
        #     Meteor.users.update transfer._author_id,
        #         $inc:credit:transfer.price_per_serving
        #     Meteor.call 'calc_transfer_data', transfer_id, ->



if Meteor.isClient
    Template.user_transfer_item.onCreated ->
        # @autorun => Meteor.subscribe 'product_from_transfer_id', @data._id
    Template.user_transfers.onCreated ->
        @autorun => Meteor.subscribe 'user_transfers', Router.current().params.username
        @autorun => Meteor.subscribe 'model_docs', 'product'
    Template.user_transfers.helpers
        transfers: ->
            current_user = Meteor.users.findOne username:Router.current().params.username
            Docs.find {
                model:'transfer'
            }, sort:_timestamp:-1

if Meteor.isServer
    # Meteor.publish 'user_transfers', (username)->
    #     # user = Meteor.users.findOne username:username
    #     Docs.find 
    #         model:'transfer'
    #         _author_username:username
            
    
    Meteor.publish 'user_transfers', (username)->
        user = Meteor.users.findOne username:username
        Docs.find {
            model:'transfer'
            _author_id: user._id
        }, 
            limit:20
            sort:_timestamp:-1
            
    Meteor.publish 'product_from_transfer_id', (transfer_id)->
        transfer = Docs.findOne transfer_id
        Docs.find
            model:'product'
            _id: transfer.product_id


if Meteor.isClient
    Router.route '/transfer/:doc_id/edit', (->
        @layout 'layout'
        @render 'transfer_edit'
        ), name:'transfer_edit'



    Template.transfer_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'source'

    Template.transfer_edit.onRendered ->
        # Meteor.setTimeout ->
        #     today = new Date()
        #     $('#availability')
        #         .calendar({
        #             inline:true
        #             # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
        #             # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
        #         })
        # , 2000

    Template.transfer_edit.helpers
        balance_after_purchase: ->
            Meteor.user().points - @purchase_amount
        percent_difference: ->
            balance_after_purchase = 
                Meteor.user().points - @purchase_amount
            # difference
            @purchase_amount/Meteor.user().points
    Template.transfer_edit.events
        'click .complete_transfer': (e,t)->
            console.log @
            Session.set('transfering',true)
            if @purchase_amount
                if Meteor.user().points and @purchase_amount < Meteor.user().points
                    Meteor.call 'complete_transfer', @_id, =>
                        Router.go "/product/#{@product_id}"
                        Session.set('transfering',false)
                else 
                    alert "not enough points"
                    Router.go "/user/#{Meteor.user().username}/points"
                    Session.set('transfering',false)
            else 
                alert 'no purchase amount'
            
            
        'click .delete_transfer': ->
            Docs.remove @_id
            Router.go "/"


    Template.linked_product.onCreated ->
        # console.log @data
        @autorun => Meteor.subscribe 'doc_by_id', @data.product_id, ->

    Template.linked_product.helpers
        linked_product_doc: ->
            console.log @
            Docs.findOne @product_id
            
            
if Meteor.isServer
    Meteor.methods  
        complete_transfer: (transfer_id)->
            console.log 'completing transfer', transfer_id
            current_transfer = Docs.findOne transfer_id            
            Docs.update transfer_id, 
                $set:
                    status:'purchased'
                    purchased:true
                    purchase_timestamp: Date.now()
            console.log 'marked complete'
            Meteor.call 'calc_user_points', @_author_id, ->
                
                
                
                
if Meteor.isClient
    Template.transfer_view.onCreated ->
        @autorun => Meteor.subscribe 'product_from_transfer_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'all_users'
        
    Template.transfer_view.onRendered ->



if Meteor.isServer
    Meteor.publish 'product_from_transfer_id', (transfer_id)->
        transfer = Docs.findOne transfer_id
        Docs.find 
            _id:transfer.product_id


if Meteor.isClient
    Template.transfer_edit.onCreated ->
        @autorun => Meteor.subscribe 'recipient_from_transfer_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => @subscribe 'tag_results',
            # Router.current().params.doc_id
            picked_tags.array()
            Session.get('searching')
            Session.get('current_query')
            Session.get('dummy')
        
    Template.transfer_edit.onRendered ->


    Template.transfer_edit.helpers
        terms: ->
            Terms.find()
        suggestions: ->
            Tags.find()
        recipient: ->
            transfer = Docs.findOne Router.current().params.doc_id
            if transfer.recipient_id
                Meteor.users.findOne
                    _id: transfer.recipient_id
        members: ->
            transfer = Docs.findOne Router.current().params.doc_id
            Meteor.users.find({
                # levels: $in: ['member','domain']
                _id: $ne: Meteor.userId()
            }, {
                sort:points:1
                limit:10
                })
        # subtotal: ->
        #     transfer = Docs.findOne Router.current().params.doc_id
        #     transfer.amount*transfer.recipient_ids.length
        
        point_max: ->
            if Meteor.user().username is 'one'
                1000
            else 
                Meteor.user().points
        
        can_submit: ->
            transfer = Docs.findOne Router.current().params.doc_id
            transfer.amount and transfer.recipient_id
    Template.transfer_edit.events
        'click .add_recipient': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    recipient_id:@_id
        'click .remove_recipient': ->
            Docs.update Router.current().params.doc_id,
                $unset:
                    recipient_id:1
        'keyup .new_tag': _.throttle((e,t)->
            query = $('.new_tag').val()
            if query.length > 0
                Session.set('searching', true)
            else
                Session.set('searching', false)
            Session.set('current_query', query)
            
            if e.which is 13
                element_val = t.$('.new_tag').val().toLowerCase().trim()
                Docs.update Router.current().params.doc_id,
                    $addToSet:tags:element_val
                picked_tags.push element_val
                Meteor.call 'log_term', element_val, ->
                Session.set('searching', false)
                Session.set('current_query', '')
                Session.set('dummy', !Session.get('dummy'))
                t.$('.new_tag').val('')
        , 1000)

        'click .remove_element': (e,t)->
            element = @valueOf()
            field = Template.currentData()
            picked_tags.remove element
            Docs.update Router.current().params.doc_id,
                $pull:tags:element
            t.$('.new_tag').focus()
            t.$('.new_tag').val(element)
            Session.set('dummy', !Session.get('dummy'))
    
    
        'click .select_term': (e,t)->
            # picked_tags.push @title
            Docs.update Router.current().params.doc_id,
                $addToSet:tags:@title
            picked_tags.push @title
            $('.new_tag').val('')
            Session.set('current_query', '')
            Session.set('searching', false)
            Session.set('dummy', !Session.get('dummy'))

    
        'blur .edit_description': (e,t)->
            textarea_val = t.$('.edit_textarea').val()
            Docs.update Router.current().params.doc_id,
                $set:description:textarea_val
    
    
        'blur .edit_text': (e,t)->
            val = t.$('.edit_text').val()
            Docs.update Router.current().params.doc_id,
                $set:"#{@key}":val
    
    
        'blur .point_amount': (e,t)->
            # console.log @
            val = parseInt t.$('.point_amount').val()
            Docs.update Router.current().params.doc_id,
                $set:amount:val



        'click .cancel_transfer': ->
            Swal.fire({
                title: "confirm cancel?"
                text: ""
                icon: 'question'
                showCancelButton: true,
                confirmButtonColor: 'red'
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Docs.remove @_id
                    Router.go '/'
            )
            
        'click .submit': ->
            Swal.fire({
                title: "confirm send #{@amount}pts?"
                text: ""
                icon: 'question'
                showCancelButton: true,
                confirmButtonColor: 'green'
                confirmButtonText: 'confirm'
                cancelButtonText: 'cancel'
                reverseButtons: true
            }).then((result)=>
                if result.value
                    Meteor.call 'send_transfer', @_id, =>
                        Swal.fire(
                            title:"#{@amount} sent"
                            icon:'success'
                            showConfirmButton: false
                            position: 'top-end',
                            timer: 1000
                        )
                        Router.go "/transfer/#{@_id}/view"
            )


    Template.transfer_edit.helpers
    Template.transfer_edit.events

if Meteor.isServer
    Meteor.methods
        send_transfer: (transfer_id)->
            transfer = Docs.findOne transfer_id
            recipient = Meteor.users.findOne transfer.recipient_id
            transferer = Meteor.users.findOne transfer._author_id

            console.log 'sending transfer', transfer
            Meteor.call 'recalc_one_stats', recipient._id, ->
            Meteor.call 'recalc_one_stats', transfer._author_id, ->
    
            Docs.update transfer_id,
                $set:
                    submitted:true
                    submitted_timestamp:Date.now()
            return                