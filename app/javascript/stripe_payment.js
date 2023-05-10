document.addEventListener("DOMContentLoaded", function () {
  const stripe = Stripe("[STRIPE_PUB_KEY]");
  const elements = stripe.elements();

  const style = {
    base: {
      color: "#32325d",
      fontFamily: "Arial, sans-serif",
      fontSmoothing: "antialiased",
      fontSize: "16px",
      "::placeholder": {
        color: "#aab7c4",
      },
    },
    invalid: {
      color: "#fa755a",
      iconColor: "#fa755a",
    },
  };

  const card = elements.create("card", { style: style });
  card.mount("#card-element");

  card.addEventListener("change", function (event) {
      const displayError = document.getElementById("card-errors");
    if (event.error) {
      displayError.textContent = event.error.message;
    } else {
      displayError.textContent = "";
    }
  });

  const form = document.getElementById("new_user");
  form.addEventListener("submit", function (event) {
    event.preventDefault();

    stripe.createToken(card).then(function (result) {
      if (result.error) {
        const errorElement = document.getElementById("card-errors");
        errorElement.textContent = result.error.message;
      } else {
        const tokenInput = document.getElementById("stripeToken");
        tokenInput.value = result.token.id;
        form.submit();
      }
    });
  });
});

