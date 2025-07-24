const showMessage = (type, text) => {
    const msg = document.getElementById("message");
    msg.textContent = text;
    msg.style.color = type === "success" ? "lightgreen" : "red";
};

window.addEventListener("message", function (event) {
    const data = event.data;
    if (data.type === "openUI") {
        // console.log("Received licenseList:", data.licenseList);

        document.body.style.display = "flex";
        document.getElementById("tablet").style.display = "flex";

        const select = document.getElementById("playerSelect");
        select.innerHTML = '<option disabled selected>Select a player</option>';
        window._licenseList = {};
        window._certPlayers = {};
        window._licenseList = data.licenseList || {};
        data.players.forEach(p => {
            window._certPlayers[p.id] = p;

            const o = document.createElement("option");
            o.value = p.id;
            o.textContent = `#${p.id} - ${p.name} (${p.job})`;
            select.appendChild(o);
        });

        // Reset checkboxes
        // document.querySelectorAll('.checkboxes input[type=checkbox]').forEach(cb => {
        //     cb.checked = false;
        //     cb.disabled = true;
        // });
        const container = document.getElementById("licenseCheckboxes");
        container.innerHTML = ""; // Clear previous entries

        data.licenseList && Object.entries(data.licenseList).forEach(([key, info]) => {
            const label = document.createElement("label");
            label.innerHTML = `<input type="checkbox" id="${key}" /> ${info.label}`;
            container.appendChild(label);
        });

        showMessage("success", "Select a player to view certifications");
    }
});

document.getElementById("playerSelect").addEventListener("change", function () {
    const selectedId = this.value;
    const player = window._certPlayers[selectedId] || {};
    const licenses = player.licenses || {};
    const job = (player.job || "").toUpperCase();
    const isEMS = job === "EMS" || job === "FIRE";

    // document.getElementById("opt1").checked = !!licenses["service_taser"];
    // document.getElementById("opt2").checked = !!licenses["service_pistol"];
    // document.getElementById("opt3").checked = !!licenses["service_shotgun"];
    // document.getElementById("opt4").checked = !!licenses["service_rifle"];
    // document.getElementById("opt5").checked = !!licenses["service_sniper"];
    // document.getElementById("opt6").checked = !!licenses["service_pdw"];
    // document.getElementById("opt7").checked = !!licenses["service_40mm"];
    // document.getElementById("opt8").checked = !!licenses["swat"];

    // // Enable/disable
    // document.getElementById("opt1").disabled = false;
    // document.getElementById("opt2").disabled = false;
    // document.getElementById("opt3").disabled = isEMS;
    // document.getElementById("opt4").disabled = isEMS;
    // document.getElementById("opt5").disabled = isEMS;
    // document.getElementById("opt6").disabled = isEMS;
    // document.getElementById("opt7").disabled = isEMS;
    // document.getElementById("opt8").disabled = isEMS;

    Object.entries(window._licenseList || {}).forEach(([key, info]) => {
        const checkbox = document.getElementById(key);
        if (checkbox) {
            checkbox.checked = !!licenses[info.id];
            checkbox.disabled = isEMS;
        }
    });


    showMessage("success", `Loaded certifications for ${player.name || 'Unknown'}`);
});


// document.getElementById("submitBtn").addEventListener("click", () => {
//     const id = document.getElementById("playerSelect").value;
//     const payload = {
//         targetId: id,
//         options: {
//             opt1: document.getElementById("opt1").checked,
//             opt2: document.getElementById("opt2").checked,
//             opt3: document.getElementById("opt3").checked,
//             opt4: document.getElementById("opt4").checked,
//             opt5: document.getElementById("opt5").checked,
//             opt6: document.getElementById("opt6").checked,
//             opt7: document.getElementById("opt7").checked,
//             opt8: document.getElementById("opt8").checked
//         }
//     };

//     fetch(`https://${GetParentResourceName()}/SubmitSelection`, {
//         method: "POST",
//         body: JSON.stringify(payload),
//         headers: { "Content-Type": "application/json" }
//     });

//     showMessage("success", "Submitted!");
// });

document.getElementById("submitBtn").addEventListener("click", () => {
    const id = document.getElementById("playerSelect").value;
    const options = {};

    Object.keys(window._licenseList || {}).forEach(key => {
        const checkbox = document.getElementById(key);
        options[key] = checkbox ? checkbox.checked : false;
    });

    const payload = {
        targetId: id,
        options: options
    };

    fetch(`https://${GetParentResourceName()}/SubmitSelection`, {
        method: "POST",
        body: JSON.stringify(payload),
        headers: { "Content-Type": "application/json" }
    });

    // console.log("Submitting payload:", payload);
    showMessage("success", "Submitted!");
});

document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
        fetch(`https://${GetParentResourceName()}/closeUI`, { method: "POST" });
        document.body.style.display = "none";
        document.getElementById("tablet").style.display = "none";
    }
});
