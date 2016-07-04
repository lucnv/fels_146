$(document).on 'click', 'form .remove_fields', (event) ->
  $(this).parent().parent().find('input[type=hidden]').val(true)
  $(this).closest('fieldset').hide()
  event.preventDefault()

$(document).on 'click', 'form .add_fields', (event) ->
  if count_answers() >= 6
    alert 'You can not add any more answer!'
  else
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('word-answers').replace(regexp, time))
    event.preventDefault()

$(document).on 'click', 'form .action .btn-primary', (event) ->

count_answers = ->
  count = 0
  for answer in $('fieldset')
    was_destroyed = $(answer).find('.destroy_tag').val()
    if was_destroyed is 'false'
      count += 1
  count

$(document).on 'change', '#category', (event) ->
  $(this).parent().submit()
