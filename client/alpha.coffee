Template.alpha.onRendered ->
    # console.log @data
    # unless @data.watson
    #     # console.log 'call'
    #     Meteor.call 'call_watson', @data._id, 'url','url',->
    # if @data.response
    # window.speechSynthesis.cancel()
    # window.speechSynthesis.speak new SpeechSynthesisUtterance @data.response.queryresult.pods[1].subpods[1].plaintext
    if @data.voice
        window.speechSynthesis.speak new SpeechSynthesisUtterance @data.voice
    else
        window.speechSynthesis.speak new SpeechSynthesisUtterance @data.response.queryresult.pods[1].subpods[0].plaintext
    # console.log response.queryresult.pods[1].subpods
    # Meteor.setTimeout( =>
    # , 7000)

Template.alpha.helpers
    split_datatypes: ->
        # console.log 'data', @
        split = @datatypes.split ','
        console.log split
        split

Template.alpha.events
    'click .select_datatype': ->
        console.log @
        selected_tags.push @valueOf().toLowerCase()
    'click .alphatemp': ->
        console.log @plaintext
        console.log @plaintext.split '|'
        window.speechSynthesis.cancel()
        window.speechSynthesis.speak new SpeechSynthesisUtterance @plaintext
        
