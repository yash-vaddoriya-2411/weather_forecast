// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
document.addEventListener("DOMContentLoaded", () => {
    const form = document.querySelector("form");
    const submitBtn = document.getElementById("submit-btn");
    const spinner = document.getElementById("custom-spinner");

    if (form && submitBtn && spinner) {
        form.addEventListener("submit", () => {
            submitBtn.disabled = true;
            spinner.classList.remove("d-none");
        });
    }
});