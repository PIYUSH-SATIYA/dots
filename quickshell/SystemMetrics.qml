import QtQuick

Row {
	id: root

	function temperatureIcon(value) {
		if (value >= 80)
			return ""

		if (value >= 65)
			return ""

		if (value >= 50)
			return ""

		if (value >= 35)
			return ""

		return ""
	}

	BarChunk {
		text: Stats.cores
		fontSize: 14
		color: Colors.foreground
	}

	BarChunk {
		text: " CPU " + Stats.cpu + "%"
		color: Stats.cpu >= 90 ? Colors.color2 : (Stats.cpu >= 65 ? Colors.warning : Colors.foreground)
	}

	BarChunk {
		text: " MEM " + Stats.memUsed.toFixed(1) + "G"
		color: Stats.memPct >= 90 ? Colors.color2 : (Stats.memPct >= 65 ? Colors.warning : Colors.foreground)
	}

	BarChunk {
		text: " " + root.temperatureIcon(Stats.temp) + " " + Stats.temp + "°"
		color: Stats.temp >= 80 ? Colors.color2 : (Stats.temp >= 65 ? Colors.warning : Colors.foreground)
	}

	BarChunk {
		text: "  " + Stats.load
		color: Colors.foreground
	}

}
