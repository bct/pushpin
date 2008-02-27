function deletedEntry(tr) {
  tr.fadeOut(function() { $(this).remove(); });
}

function failDeleteEntry(xhr, tr) {
  var statustd = tr.children(":last")
  if (xhr.status == 401) {
    params = eval('(' + xhr.responseText + ')');
    if(params.status == "unauthorized") {
      delete params.response;
      var auth_url = delAuthUrlPrefix + jQuery.param(params);
      statustd.html("<a href='" + auth_url + "'>enter login data</a>.");
    } else if (params.status == "needtokenauth") {
      statustd.html("<a href='" + params.redirect_to + "'>enter login data</a>.");
    }
  } else {
    statustd.text("unknown error.");
  }
}

$(document).ready(function(){
  $(".delete").click(function(){
    $(this).attr("disabled", "disabled");
    var form = $(this).parents("form");

    var tr = $(this).parents("tr");

    tr.append('<td>' + spinnerImg + '</td>')

    $.ajax({ type: "POST",
             url: form.attr("action"),
             beforeSend: function(xhr) { xhr.setRequestHeader("Accept", "application/json") },
             data: form.serialize(),
             dataType: "json",
             success: function(data, textstatus) { deletedEntry(tr) },
             error: function(xhr, textstatus, error) { failDeleteEntry(xhr, tr) }
             })

    return false;
  });
});
