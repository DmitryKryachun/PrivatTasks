
$directory = "C:\log"

$currentDate = Get-Date

for ($i = 1; $i -le 100; $i++) {

    $currentDate = $currentDate.AddDays(1)
    

    $dateString = $currentDate.ToString("yyyyMMdd")
    

    $fileName = "{0}\{1}.log" -f $directory, $dateString

    $content = Get-Random -Minimum 100 -Maximum 1000 | Out-String

	for ($j = 1; $j -le $content; $j++) {
		Add-Content -Path $fileName -Value "TEST_TEXT_FOR_TASK_1_KRIACHUN_TEST_TEXT_FOR_TASK_1_KRIACHUN_TEST_TEXT_FOR_TASK_1_KRIACHUN_TEST_TEXT_FOR_TASK_1_KRIACHUN_"
	}
}