<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>

<?php
require_once __DIR__ . '/src/helpers.php';

const WORK_DEFAULT = 'foundation';
const OBJECT_DEFAULT = 'Airport';
const START_DATA = '2020-01-01';
const END_DATA = '2025-04-30';



$startDate = isset($_POST['start_date']) ? trim($_POST['start_date'] . '-01') : START_DATA;
$endDate = isset($_POST['end_date']) ? trim($_POST['end_date'] . '-30') : END_DATA;
$object = isset($_POST['object']) ? trim($_POST['object']) : OBJECT_DEFAULT;
$workType = isset($_POST['work_type']) ? trim($_POST['work_type']) : WORK_DEFAULT;

/** Получение данных с накоплением */
$results = getAccumulateData($startDate, $endDate, $object, $workType);

foreach ($results as $row) {
    $accumulatedDataMonthYear[] = $row['month_year'];
    $accumulatedPlane[] = $row['cumulative_planned_amount'];
    $accumulatedFact[] = $row['cumulative_actual_amount'];
}

$dataJson = json_encode($accumulatedDataMonthYear);
$planeJson = json_encode($accumulatedPlane);
$factJson = json_encode($accumulatedFact);
/************************************************ */

/** Получение данных без  накопления */
$results = getNotAccumulateData($startDate, $endDate, $object, $workType);

foreach ($results as $row) {
    $dataMonthYear[] = $row['month_year'];
    $plane[] = $row['plan_amount'];
    $fact[] = $row['act_amount'];
}

$dataJson2 = json_encode($dataMonthYear);
$planeJson2 = json_encode($plane);
$factJson2 = json_encode($fact);
/************************************************ */

?>

<body>
    <h1>Форма для ввода данных</h1>
    <form action="" method="post">
        <label for="start_date">Дата начала:</label>
        <select id="start_date" name="start_date" required>
            <option value="">Выберите дату начала</option>
            <?php
            foreach (getDates() as $value) {
                $selected = ($value == mb_substr($startDate, 0, -3)) ? 'selected' : '';
            ?>
                <option <?= $selected ?> value=<?= $value ?>><?= $value ?></option>
            <?php } ?>
        </select><br><br>

        <label for="end_date">Дата окончания:</label>
        <select id="end_date" name="end_date" required>
            <option value="">Выберите дату окончания</option>
            <?php
            foreach (getDates() as $value) {
                $selected = ($value == mb_substr($endDate, 0, -3)) ? 'selected' : '';
            ?>
                <option <?= $selected ?> value=<?= $value ?>><?= $value ?></option>
            <?php } ?>
        </select><br><br>

        <label for="object">Объект:</label>
        <select id="object" name="object" required>
            <option value="">Выберите объект</option>
            <?php
            foreach (getObjects() as $value) {
                $selected = ($value == $object) ? 'selected' : '';
            ?>
                <option <?= $selected ?> value=<?= $value ?>><?= $value ?></option>
            <?php } ?>
        </select><br><br>

        <label for="work_type">Тип работы:</label>
        <select id="work_type" name="work_type" required>
            <option value="">Выберите тип работы</option>
            <?php
            foreach (getWorks() as $value) {
                $selected = ($value == $workType) ? 'selected' : '';
            ?>
                <option <?= $selected ?> value=<?= $value ?>><?= $value ?></option>
            <?php } ?>
        </select><br><br>

        <input type="submit" value="Вывести данные">
    </form>
    <CENTER>
        <h2>Данные для объекта: <?= $object ?> типа работ: <?= $workType ?> с <?= $startDate ?> по <?= $endDate ?> (с накопительным итогом)</h2>
    </CENTER>
    <div>
        <canvas id="myChart" style="display: block; box-sizing: border-box; height: 20%; width: 100%;"></canvas>
    </div>
    <CENTER>
        <h2>Данные для объекта: <?= $object ?> типа работ: <?= $workType ?> с <?= $startDate ?> по <?= $endDate ?> (без накопительного итога)</h2>
    </CENTER>
    <div>
        <canvas id="myChart2" style="display: block; box-sizing: border-box; height: 20%; width: 100%;"></canvas>
    </div>

    <script>
        const dataJ = <?php echo $dataJson; ?>;
        const planeJ = <?php echo $planeJson; ?>;
        const factJ = <?php echo $factJson; ?>;

        const dataJ2 = <?php echo $dataJson2; ?>;
        const planeJ2 = <?php echo $planeJson2; ?>;
        const factJ2 = <?php echo $factJson2; ?>;

        const ctx = document.getElementById('myChart').getContext("2d");
        const ctx2 = document.getElementById('myChart2').getContext("2d");

        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: dataJ,
                datasets: [{
                        label: "Плановая Стоимость ",
                        fillColor: "blue",
                        data: planeJ
                    },
                    {
                        label: "Фактическая Стоимость",
                        fillColor: "red",
                        data: factJ
                    },
                ]
            },
            options: {
                scales: {
                    y: {
                        title: {
                            display: true,
                            text: 'тыс. руб.'
                        },
                        beginAtZero: true
                    }
                }
            }
        });
        new Chart(ctx2, {
            type: 'bar',
            data: {
                labels: dataJ2,
                datasets: [{
                        label: "Плановая Стоимость ",
                        fillColor: "blue",
                        data: planeJ2
                    },
                    {
                        label: "Фактическая Стоимость",
                        fillColor: "red",
                        data: factJ2
                    },
                ]
            },
            options: {
                width: 300,
                height: 200,
                scales: {
                    y: {
                        title: {
                            display: true,
                            text: 'тыс. руб.'
                        },
                        beginAtZero: true
                    }
                }
            }
        });
    </script>

</body>