$(document).ready ->
    $("form").on("ajax:success", (event) ->
        [data, status, xhr] = event.detail
        console.log("Transaction updated successfully.")
        $(this).parent()
          .append '<p class="alert alert-success mt-1"><i class="fas fa-check"></i> Updated successfully.</p>'
        alert = $(this).parent().find('p')
        alert.hide()
          .slideDown()
          .delay 2000
          .slideUp('fast', () -> alert.remove() )
      ).on "ajax:error", (event) ->
        console.log("Error in request")
