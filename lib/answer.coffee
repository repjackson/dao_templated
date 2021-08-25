if Meteor.isClient
    Template.pick_rating.onRendered ->
        Meteor.setTimeout =>
            $('.ui.rating').rating(
                # icon: 'pizza slice',
                # initialRating: 3,
                maxRating: 10
                onRate:(val)->
                    console.log val
                    console.log Router.current().params.doc_id
                    Docs.update Router.current().params.doc_id,
                        $set:answer_rating:val
                        
            )
        , 1000
    Template.rating_read.onRendered ->
        Meteor.setTimeout =>
            $('.ui.rating').rating(
                # icon: 'pizza slice',
                # initialRating: 3
                interactive:false
                disabled:true
                maxRating: 10
                # onRate:(val)->
                #     console.log val
                #     console.log Router.current().params.doc_id
                #     Docs.update Router.current().params.doc_id,
                #         $set:answer_rating:val
                        
            )
        , 2000
            
    Template.answer_edit.onCreated ->
        @autorun => Meteor.subscribe 'question_from_answer_id', Router.current().params.doc_id
        @autorun => Meteor.subscribe 'question_choices_from_answer_id', Router.current().params.doc_id
        # @autorun => Meteor.subscribe 'model_docs', 'question_choice'
        @autorun => Meteor.subscribe 'doc', Router.current().params.doc_id, ->
        @autorun => Meteor.subscribe 'unanswered_users', Router.current().params.doc_id, ->
    Template.answer_edit.helpers
        question_doc: ->
            current_answer = Docs.findOne Router.current().params.doc_id
            Docs.findOne 
                model:'question'
                _id:current_answer.question_id
        answer_choice_docs: ->
            current_answer = Docs.findOne Router.current().params.doc_id
            Docs.find   
                model:'question_choice'
                parent_id:current_answer.question_id
        unanswered_users: ->
            current_answer = Docs.findOne Router.current().params.doc_id
            found_answers = 
                Docs.find(
                    model:'answer'
                    question_id:Router.current().params.doc_id
                ).fetch()
            answered_users = []
            for answer in found_answers
                console.log 'answer', answer
                if answer.answer_username
                    console.log 'answer', answer.answer_username
                    answered_users.push answer.answer_username
            console.log answered_users
            Meteor.users.find
                username:$nin:answered_users
                app:'bc'
                
        user_picker_class: ->
            current_answer = Docs.findOne Router.current().params.doc_id
            if current_answer.answer_username is @username then 'black' else 'basic'
        choice_class: ->
            current_answer = Docs.findOne Router.current().params.doc_id
            if current_answer.answer_choice_id is @_id then 'black' else 'basic'
        yes_class: ->
            current_answer = Docs.findOne Router.current().params.doc_id
            if current_answer.answer_title is 'yes' then 'green' else 'basic'
        no_class: ->
            current_answer = Docs.findOne Router.current().params.doc_id
            if current_answer.answer_title is 'no' then 'red' else 'basic'
    Template.answer_edit.events
        'click .cancel_answer': ->
            Docs.remove @_id
            Router.go "/question/#{@question_id}"
        
        'click .choose_answer': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    answer_choice_id: @_id
                    answer_title: @title
        'click .yes': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    answer_boolean: true
                    answer_title: 'yes'
        'click .no': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    answer_boolean: false
                    answer_title: 'no'
        'click .choose_user': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    answer_user_id: @_id
                    answer_username: @username
            
        'click .complete_answer': ->
            Docs.update Router.current().params.doc_id,
                $set:
                    complete:true
            Router.go "/question/#{@question_id}"
