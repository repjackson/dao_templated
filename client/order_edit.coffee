Router.route '/order/:doc_id/edit', (->
    @layout 'layout'
    @render 'order_edit'
    ), name:'order_edit'
Template.order_edit.onCreated ->
    @autorun => Meteor.subscribe 'target_from_order_id', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'author_from_doc_id', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
    @autorun => Meteor.subscribe 'all_users', ->
    @autorun => @subscribe 'tag_results',
        # Router.current().params.doc_id
        picked_tags.array()
        Session.get('searching')
        Session.get('current_query')
        Session.get('dummy')
    

Template.order_edit.onCreated ->
    @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
    # @autorun => Meteor.subscribe 'model_docs', 'source'

Template.order_edit.onRendered ->
    # Meteor.setTimeout ->
    #     today = new Date()
    #     $('#availability')
    #         .calendar({
    #             inline:true
    #             # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
    #             # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
    #         })
    # , 2000

Template.order_edit.helpers
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
        order = Docs.findOne Router.current().params.doc_id
        if order.target_id
            Meteor.users.findOne
                _id: order.target_id
    members: ->
        order = Docs.findOne Router.current().params.doc_id
        Meteor.users.find({
            # levels: $in: ['member','domain']
            _id: $ne: Meteor.userId()
        }, {
            sort:points:1
            limit:10
            })
    # subtotal: ->
    #     order = Docs.findOne Router.current().params.doc_id
    #     order.amount*order.target_ids.length
    
    point_max: ->
        if Meteor.user().username is 'one'
            1000
        else 
            Meteor.user().points
    
    can_submit: ->
        order = Docs.findOne Router.current().params.doc_id
        order.amount and order.target_id


Template.order_edit.events
    # 'click .complete_order': (e,t)->
    #     Session.set('ordering',true)
    #     if @purchase_amount
    #         if Meteor.user().points and @purchase_amount < Meteor.user().points
    #             Meteor.call 'complete_order', @_id, =>
    #                 Router.go "/product/#{@product_id}"
    #                 Session.set('ordering',false)
    #         else 
    #             alert "not enough points"
    #             Router.go "/user/#{Meteor.user().username}/points"
    #             Session.set('ordering',false)
    #     else 
    #         alert 'no purchase amount'
        
        
    'click .delete_order': ->
        Docs.remove @_id
        Router.go "/"


    'click .parse_quick_add': ->
        split = @quick_add.split(' ')
        if split[0] is 'send'
            Docs.update Router.current().params.doc_id, 
                $set:
                    amount:parseInt(split[1])

    'click .add_target': ->
        Docs.update Router.current().params.doc_id,
            $set:
                target_id:@_id
    'click .remove_target': ->
        Docs.update Router.current().params.doc_id,
            $unset:
                target_id:1
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


    # 'click .select_term': (e,t)->
    #     # picked_tags.push @title
    #     Docs.update Router.current().params.doc_id,
    #         $addToSet:tags:@title
    #     picked_tags.push @title
    #     $('.new_tag').val('')
    #     Session.set('current_query', '')
    #     Session.set('searching', false)
    #     Session.set('dummy', !Session.get('dummy'))


    'click .cancel_order': ->
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
            Router.go '/posts'
        )
        
    'click .confirm_order': (e,t)->
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
        Meteor.call 'confirm_order', @_id, (err,res)=>
            if err
                console.log err
                # $('body').toast(
                #     showIcon: 'checkmark'
                #     message: "post access bought for #{@price}"
                #     # showProgress: 'bottom'
                #     class: 'success'
                #     # displayTime: 'auto',
                #     position: "bottom right"
                # )
                Swal.fire({
                    title: err.error
                    text: ""
                    icon: 'question'
                    showCancelButton: true,
                    confirmButtonColor: 'green'
                    confirmButtonText: 'confirm'
                    cancelButtonText: 'cancel'
                    reverseButtons: true
                }).then((result)=>
                    # if result.value
                )
                    
            else 
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
                    message: "post access bought for #{@price}"
                    # showProgress: 'bottom'
                    class: 'success'
                    # displayTime: 'auto',
                    position: "bottom right"
                )
                Router.go "/post/#{@post_id}"

        # )