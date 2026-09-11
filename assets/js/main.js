/* A member form (subscribe, sign-in) hides its row on success, which drops focus; move it to the message. */
(function () {
    document.querySelectorAll('.subscribe').forEach(function (form) {
        new MutationObserver(function () {
            if (form.classList.contains('success')) form.querySelector('.subscribe-success').focus();
        }).observe(form, {attributes: true, attributeFilter: ['class']});
    });
})();

/* The footer's sign-in opens its form in a dialog: the link shows it; Escape, the close button
   and a click on the backdrop (the dialog itself, outside its padded inner box) close it. */
(function () {
    var dialog = document.getElementById('signin');
    if (!dialog) return;
    document.querySelector('[data-signin-open]').addEventListener('click', function () { dialog.showModal(); });
    dialog.querySelector('[data-signin-close]').addEventListener('click', function () { dialog.close(); });
    dialog.addEventListener('click', function (e) { if (e.target === dialog) dialog.close(); });
})();
