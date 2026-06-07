const showMessage = (type, text) => {
    const msg = document.getElementById("message");
    msg.textContent = text;
    msg.style.color = type === "success" ? "lightgreen" : "red";
};

const closeUI = () => {
    document.body.style.display = "none";
    document.getElementById("tablet").style.display = "none";
    window._mode = "certificates";
    window._optionList = {};
    window._certPlayers = {};
};

const getAllowedTypes = (required) => {
    if (Array.isArray(required)) {
        return required.map(r => String(r).toLowerCase());
    }

    if (typeof required === "string" && required.trim() !== "") {
        return [required.toLowerCase()];
    }

    return [];
};

const hasAward = (player, awardInfo) => {
    const awards = Array.isArray(player.awards) ? player.awards : [];
    const title = String(awardInfo.id || "");

    return awards.some(entry => {
        return entry && typeof entry === "object" && String(entry.title || "") === title;
    });
};

const hasCertificate = (player, optionInfo) => {
    const licenses = player.licenses || {};
    return !!licenses[optionInfo.id];
};

const refreshCheckboxesForPlayer = (player) => {
    const playerJob = String(player.job || "").toLowerCase();
    const isAwardsMode = window._mode === "awards";

    Object.entries(window._optionList || {}).forEach(([key, info]) => {
        const checkbox = document.getElementById(key);
        if (!checkbox) return;

        const allowedTypes = getAllowedTypes(info.required);
        const isAllowed = allowedTypes.length === 0 || allowedTypes.includes(playerJob);

        checkbox.disabled = !isAllowed;

        if (isAwardsMode) {
            checkbox.checked = hasAward(player, info);
        } else {
            checkbox.checked = hasCertificate(player, info);
        }
    });
};

window.addEventListener("message", function (event) {
    const data = event.data;

    if (data.type === "openUI") {
        document.body.style.display = "flex";
        document.getElementById("tablet").style.display = "flex";

        const title = document.querySelector(".tablet-screen h2");
        title.innerHTML = data.mode === "awards"
            ? '<i class="fas fa-medal"></i> Grant/Revoke Awards'
            : '<i class="fas fa-id-badge"></i> Grant/Revoke Certifications';

        const select = document.getElementById("playerSelect");
        select.innerHTML = '<option disabled selected value="">Select a player</option>';

        window._mode = data.mode || "certificates";
        window._optionList = data.optionList || {};
        window._certPlayers = {};

        (data.players || []).forEach(p => {
            window._certPlayers[p.id] = p;

            const option = document.createElement("option");
            option.value = p.id;
            option.textContent = `#${p.id} - ${p.name} (${p.job})`;
            select.appendChild(option);
        });

        const container = document.getElementById("licenseCheckboxes");
        container.innerHTML = "";

        Object.entries(window._optionList).forEach(([key, info]) => {
            const label = document.createElement("label");
            label.innerHTML = `<input type="checkbox" id="${key}" /> ${info.label}`;
            container.appendChild(label);
        });

        showMessage("success", data.mode === "awards"
            ? "Select a player to view awards"
            : "Select a player to view certifications");
    }

    if (data.type === "closeUI") {
        closeUI();
    }
});

document.getElementById("playerSelect").addEventListener("change", function () {
    const selectedId = this.value;
    const player = window._certPlayers[selectedId] || {};

    refreshCheckboxesForPlayer(player);

    showMessage(
        "success",
        window._mode === "awards"
            ? `Loaded awards for ${player.name || "Unknown"}`
            : `Loaded certifications for ${player.name || "Unknown"}`
    );
});

document.getElementById("submitBtn").addEventListener("click", () => {
    const id = document.getElementById("playerSelect").value;

    if (!id) {
        showMessage("error", "Please select a player first");
        return;
    }

    const options = {};

    Object.keys(window._optionList || {}).forEach(key => {
        const checkbox = document.getElementById(key);
        options[key] = checkbox ? checkbox.checked : false;
    });

    fetch(`https://${GetParentResourceName()}/SubmitSelection`, {
        method: "POST",
        body: JSON.stringify({
            mode: window._mode,
            targetId: id,
            options: options
        }),
        headers: { "Content-Type": "application/json" }
    });

    showMessage(
        "success",
        window._mode === "awards" ? "Awards submitted!" : "Certifications submitted!"
    );
});

document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
        fetch(`https://${GetParentResourceName()}/closeUI`, { method: "POST" });
        closeUI();
    }
});