$(document).ready(function(){

  console.log('hi');


  // add button event handler
  $(".api").each(function(){
    var action = $(this).attr('action');

    var $txtarea = $(this).children('textarea');
    var param_name = $txtarea.attr('name');



    $(this).find('button').click(function(ev){
      var btnfmt = $(this).attr('data-format');
      var txt = $txtarea.val().replace(/\n+/g, ",");
      var a_url = (action + btnfmt + '?&' + param_name + '=' + txt);
      ev.stopPropagation();

      window.location.href = a_url;
    });

  });

})
