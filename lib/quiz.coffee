if Meteor.isClient
    Template.quiz.onCreated ->
        @autorun => @subscribe 'model_docs', 'quiz', ->
    Router.route '/quiz', (->
        @render 'quiz'
        ), name:'quiz'

    Template.quiz.onCreated ->
        @autorun -> Meteor.subscribe 'quizs',
            Session.get('quiz_status_filter')
        @autorun -> Meteor.subscribe 'model_docs', 'food', 20
        # @autorun -> Meteor.subscribe 'model_docs', 'thing', 100

    Template.quiz.helpers
        food_docs: ->
            Docs.find 
                model:'food'
        quizs: ->
            match = {model:'quiz'}
            # if Session.get('quiz_status_filter')
            #     match.status = Session.get('quiz_status_filter')
            # if Session.get('quiz_delivery_filter')
            #     match.delivery_method = Session.get('quiz_sort_filter')
            # if Session.get('item_sort_filter')
            #     match.delivery_method = Session.get('item_sort_filter')
            Docs.find match,
                sort: _timestamp:-1


if Meteor.isClient
    Router.route '/quiz/:doc_id', (->
        @layout 'layout'
        @render 'quiz_view'
        ), name:'quiz_view'


    Template.quiz_view.onCreated ->
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'product_by_quiz_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'quiz_things', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'review_from_quiz_id', Router.current().params.doc_id


    Template.quiz_view.events
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
      
        'click .delete_quiz': ->
            thing_count = Docs.find(model:'thing').count()
            if confirm "delete? #{thing_count} things still"
                Docs.remove @_id
                Router.go "/quizs"
    
        'click .mark_ready': ->
            if confirm 'mark ready?'
                Docs.insert 
                    model:'quiz_event'
                    quiz_id: Router.current().params.doc_id
                    quiz_status:'ready'

        'click .add_review': ->
            Docs.insert 
                model:'quiz_review'
                quiz_id: Router.current().params.doc_id
                
                
        'click .review_positive': ->
            Docs.update @_id,
                $set:
                    rating:1
        'click .review_negative': ->
            Docs.update @_id,
                $set:
                    rating:-1

    Template.quiz_view.helpers
        quiz_review: ->
            Docs.findOne 
                model:'quiz_review'
                quiz_id:Router.current().params.doc_id
    
        can_quiz: ->
            # if StripeCheckout
            unless @_author_id is Meteor.userId()
                quiz_count =
                    Docs.find(
                        model:'quiz'
                        quiz_id:@_id
                    ).count()
                if quiz_count is @servings_amount
                    false
                else
                    true
            # else
            #     false




if Meteor.isServer
    Meteor.publish 'quizs', (quiz_id, status)->
        # quiz = Docs.findOne quiz_id
        match = {model:'quiz'}
        if status 
            match.status = status

        Docs.find match
        
    Meteor.publish 'review_from_quiz_id', (quiz_id)->
        # quiz = Docs.findOne quiz_id
        # match = {model:'quiz'}
        Docs.find 
            model:'quiz_review'
            quiz_id:quiz_id
        
    Meteor.publish 'product_by_quiz_id', (quiz_id)->
        quiz = Docs.findOne quiz_id
        Docs.find
            _id: quiz.product_id
    Meteor.publish 'quiz_things', (quiz_id)->
        quiz = Docs.findOne quiz_id
        Docs.find
            model:'thing'
            quiz_id: quiz_id

    # Meteor.methods
        # quiz_quiz: (quiz_id)->
        #     quiz = Docs.findOne quiz_id
        #     Docs.insert
        #         model:'quiz'
        #         quiz_id: quiz._id
        #         quiz_price: quiz.price_per_serving
        #         buyer_id: Meteor.userId()
        #     Meteor.users.update Meteor.userId(),
        #         $inc:credit:-quiz.price_per_serving
        #     Meteor.users.update quiz._author_id,
        #         $inc:credit:quiz.price_per_serving
        #     Meteor.call 'calc_quiz_data', quiz_id, ->


if Meteor.isServer
    Meteor.publish 'product_from_quiz_id', (quiz_id)->
        quiz = Docs.findOne quiz_id
        Docs.find
            model:'product'
            _id: quiz.product_id


if Meteor.isClient
    Router.route '/quiz/:doc_id/edit', (->
        @layout 'layout'
        @render 'quiz_edit'
        ), name:'quiz_edit'



    Template.quiz_edit.onCreated ->
        @autorun => Meteor.subscribe 'doc_by_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'source'

    Template.quiz_edit.onRendered ->
        # Meteor.setTimeout ->
        #     today = new Date()
        #     $('#availability')
        #         .calendar({
        #             inline:true
        #             # minDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() - 5),
        #             # maxDate: new Date(today.getFullYear(), today.getMonth(), today.getDate() + 5)
        #         })
        # , 2000

    Template.quiz_edit.helpers
        balance_after_purchase: ->
            Meteor.user().points - @purchase_amount
        percent_difference: ->
            balance_after_purchase = 
                Meteor.user().points - @purchase_amount
            # difference
            @purchase_amount/Meteor.user().points
    Template.quiz_edit.events
        'click .complete_quiz': (e,t)->
            console.log @
            Session.set('quizing',true)
            if @purchase_amount
                if Meteor.user().points and @purchase_amount < Meteor.user().points
                    Meteor.call 'complete_quiz', @_id, =>
                        Router.go "/product/#{@product_id}"
                        Session.set('quizing',false)
                else 
                    alert "not enough points"
                    Router.go "/user/#{Meteor.user().username}/points"
                    Session.set('quizing',false)
            else 
                alert 'no purchase amount'
            
            
        'click .delete_quiz': ->
            Docs.remove @_id
            Router.go "/product/#{@product_id}"
