
let jobsData = {};
let playerData = [];

window.addEventListener('message', function(event) {
    console.log('Full message data:', event.data);
    if (event.data.action === 'openSetJob') {
        jobsData = event.data.jobs;
        playerData = event.data.players;
        console.log('Players data structure:', JSON.stringify(playerData, null, 2));
        document.getElementById('setjob-container').classList.add('visible');
        populatePlayers();
        populateJobs();
    }
});  function populatePlayers() {
      console.log('Players data:', playerData);
      const playerSelect = document.getElementById('player-id');
      playerSelect.innerHTML = '<option value="">Select Player</option>';
    
      playerData.forEach(player => {
          const option = document.createElement('option');
          option.value = player.id;
          option.textContent = `${player.name} (${player.id})`;
          playerSelect.appendChild(option);
      });
  }
function populateJobs() {
    const jobSelect = document.getElementById('job-select');
    jobSelect.innerHTML = '<option value="">Select Job</option>';
    
    Object.entries(jobsData).forEach(([jobId, jobInfo]) => {
        const option = document.createElement('option');
        option.value = jobId;
        option.textContent = jobInfo.label;
        jobSelect.appendChild(option);
    });
}
document.getElementById('job-select').addEventListener('change', function(e) {
    const gradeSelect = document.getElementById('grade-select');
    gradeSelect.innerHTML = '<option value="">Select Grade</option>';
    
    const selectedJob = jobsData[e.target.value];
    if (selectedJob && selectedJob.ranks) {
        selectedJob.ranks.forEach(rank => {
            const option = document.createElement('option');
            option.value = rank.grade;
            option.textContent = `${rank.name} - Grade ${rank.grade}`;
            gradeSelect.appendChild(option);
        });
    }
});
document.getElementById('submit-button').addEventListener('click', function() {
    const playerId = document.getElementById('player-id').value;
    const jobId = document.getElementById('job-select').value;
    const grade = document.getElementById('grade-select').value;
    
    if (playerId && jobId && grade) {
        fetch(`https://${GetParentResourceName()}/setJob`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                playerId: parseInt(playerId),
                job: jobId,
                grade: parseInt(grade)
            })
        });
        closeMenu();
    }
});

document.getElementById('close-button').addEventListener('click', closeMenu);

function closeMenu() {
    document.getElementById('setjob-container').classList.remove('visible');
    fetch(`https://${GetParentResourceName()}/closeSetJob`, {
        method: 'POST'
    });
}
