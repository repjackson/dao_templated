Template.post_view.onRendered ->

Router.route '/post/:doc_id', (->
    @layout 'layout'
    @render 'post_view'
    ), name:'post_view'


Template.post_view.onRendered ->
    Meteor.call 'log_view', Router.current().params.doc_id, ->
Template.post_view.onCreated ->
    @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'target_from_post_id', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'all_users'
    # @autorun => Meteor.subscribe 'product_by_post_id', Router.current().params.doc_id
    @autorun => Meteor.subscribe 'post_orders', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'review_from_post_id', Router.current().params.doc_id


Template.post_view.helpers  
    orders: ->
        post = Docs.findOne Router.current().params.doc_id
        # Meteor.users.find 
        #     _id: $in:post.buyer_ids
        Docs.find 
            model:'order'
            post_id:Router.current().params.doc_id
            
            
            
Template.post_view.events
    'click .purchase': (e,t)->
        post = Docs.findOne Router.current().params.doc_id
        new_order = 
            Docs.insert     
                model:'order'
                _author_id:Meteor.userId()
                _author_username:Meteor.user().username
                _timestamp:Date.now()
                post_id:Router.current().params.doc_id
                order_price:post.price
        Router.go "/order/#{new_order}/edit"
        
        
    'click .flat_tag': (e,t)->
        $(e.currentTarget).closest('.grid').transition('fly right', 500)
        # console.log @
        picked_tags.clear()
        picked_tags.push @valueOf()
        Router.go '/'
    # 'click .mark_viewed': ->
    #     # if confirm 'mark viewed?'
    #     Docs.update Router.current().params.doc_id, 
    #         $set:
    #             runner_viewed: true
    #             runner_viewed_timestamp: Date.now()
    #             runner_username: Meteor.user().username
    #             status: 'viewed' 
  
  
  Router.route '/post/:doc_id/edit', (->
    @layout 'fullscreen'
    @render 'post_edit'
    ), name:'post_edit'
Template.post_edit.onCreated ->
    @autorun => Meteor.subscribe 'target_from_post_id', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'all_users', ->
    @autorun => @subscribe 'tag_results',
        # Router.current().params.doc_id
        picked_tags.array()
        Session.get('searching')
        Session.get('current_query')
        Session.get('dummy')
    

Template.post_edit.onCreated ->
    @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'model_docs', 'source'

Template.post_edit.onRendered ->
    # Meteor.setTimeout ->
    #     today = new Date()
    #     $('#availability')
    #         .calendar({
    #             inline:true
    #             # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
    #             # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
    #         })
    # , 2000

Template.post_edit.helpers
    balance_after_purchase: ->
        Meteor.user().points - @purchase_amount
    percent_difference: ->
        balance_after_purchase = 
            Meteor.user().points - @purchase_amount
        # difference
        @purchase_amount/Meteor.user().points

    # terms: ->
    #     Terms.find()
    # suggestions: ->
    #     Tags.find()
    target: ->
        post = Docs.findOne Router.current().params.doc_id
        if post.target_id
            Meteor.users.findOne
                _id: post.target_id
    members: ->
        post = Docs.findOne Router.current().params.doc_id
        Meteor.users.find({
            # levels: $in: ['member','domain']
            _id: $ne: Meteor.userId()
        }, {
            sort:points:1
            limit:10
            })
    # subtotal: ->
    #     post = Docs.findOne Router.current().params.doc_id
    #     post.amount*post.target_ids.length
    
    point_max: ->
        if Meteor.user().username is 'one'
            1000
        else 
            Meteor.user().points
    
    can_submit: ->
        post = Docs.findOne Router.current().params.doc_id
        post.amount and post.target_id


Template.post_edit.events
    # 'click .complete_post': (e,t)->
    #     Session.set('posting',true)
    #     if @purchase_amount
    #         if Meteor.user().points and @purchase_amount < Meteor.user().points
    #             Meteor.call 'complete_post', @_id, =>
    #                 Router.go "/product/#{@product_id}"
    #                 Session.set('posting',false)
    #         else 
    #             alert "not enough points"
    #             Router.go "/user/#{Meteor.user().username}/points"
    #             Session.set('posting',false)
    #     else 
    #         alert 'no purchase amount'
        
        
    'click .delete_post': ->
        Docs.remove @_id
        Router.go "/"



    'blur .point_amount': (e,t)->
        val = parseInt t.$('.point_amount').val()
        Docs.update Router.current().params.doc_id,
            $set:amount:val



    'click .cancel_post': ->
        # Swal.fire({
        #     title: "confirm cancel?"
        #     text: ""
        #     icon: 'question'
        #     showCancelButton: true,
        #     confirmButtonColor: 'red'
        #     confirmButtonText: 'confirm'
        #     cancelButtonText: 'cancel'
        #     reverseButtons: true
        # }).then((result)=>
        # if result.value
        Docs.remove @_id
        Router.go '/'
        # )
        
    'click .submit': (e,t)->
        # Swal.fire({
        #     title: "confirm send #{@amount}pts?"
        #     text: ""
        #     icon: 'question'
        #     showCancelButton: true,
        #     confirmButtonColor: 'green'
        #     confirmButtonText: 'confirm'
        #     cancelButtonText: 'cancel'
        #     reverseButtons: true
        # }).then((result)=>
        #     if result.value
        Meteor.call 'send_post', @_id, =>
            $(e.currentTarget).closest('.grid').transition('fly right',500)
            # Swal.fire(
            #     title:"#{@amount} sent"
            #     icon:'success'
            #     showConfirmButton: false
            #     position: 'top-end',
            #     timer: 1000
            # )
            $('body').toast(
                showIcon: 'checkmark'
                message: "#{@amount} sent to #{@target_username}"
                # showProgress: 'bottom'
                class: 'success'
                # displayTime: 'auto',
                position: "bottom right"
            )

            Router.go "/post/#{@_id}"
        # )