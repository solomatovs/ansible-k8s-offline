# Мониторинг CPU в Prometheus: PromQL запросы

## 1. CPU Utilization (загрузка, %)

Показывает долю времени, когда процессор **не простаивал**.
Базовая метрика — `node_cpu_seconds_total` от node_exporter.

### Мгновенная загрузка (базовое выражение)

```promql
(1 - avg by (server) (rate(node_cpu_seconds_total{mode="idle"}[5m]))) * 100
```

### Агрегация за день

Через subquery `[1d:5m]` — окно 1 день, шаг расчёта 5 минут.

#### Средняя загрузка за день

```promql
avg_over_time(
  ((1 - avg by (server) (rate(node_cpu_seconds_total{mode="idle"}[5m]))) * 100)[1d:5m]
)
```

#### Максимальная загрузка за день

```promql
max_over_time(
  ((1 - avg by (server) (rate(node_cpu_seconds_total{mode="idle"}[5m]))) * 100)[1d:5m]
)
```

#### Минимальная загрузка за день

```promql
min_over_time(
  ((1 - avg by (server) (rate(node_cpu_seconds_total{mode="idle"}[5m]))) * 100)[1d:5m]
)
```

---

## 2. Load Average (в %)

Метрики: `node_load1`, `node_load5`, `node_load15`.
Чтобы получить проценты — делим на количество ядер.

### Мгновенный load average в %

```promql
node_load1 * 100
  / count by (server) (node_cpu_seconds_total{mode="idle"})
```

### Агрегация за день

#### Средний load average за день

```promql
avg_over_time(
  (node_load1 * 100
    / count by (server) (node_cpu_seconds_total{mode="idle"})
  )[1d:5m]
)
```

#### Максимальный load average за день

```promql
max_over_time(
  (node_load1 * 100
    / count by (server) (node_cpu_seconds_total{mode="idle"})
  )[1d:5m]
)
```

#### Минимальный load average за день

```promql
min_over_time(
  (node_load1 * 100
    / count by (server) (node_cpu_seconds_total{mode="idle"})
  )[1d:5m]
)
```

---

## 3. Настройка в Grafana

Чтобы получить **одну точку на день** (а не скользящее окно):

- **Table panel** — выбери период (например, 30 дней), установи **Min interval = `1d`** в Query options. Каждая строка — один день.
- **Time series panel** — аналогично: Min interval = `1d`, и каждая точка на графике = один день.

### Recording Rules (для экономии ресурсов)

```yaml
groups:
  - name: daily_cpu
    interval: 5m
    rules:
      - record: instance:cpu_utilization:percent
        expr: >
          (1 - avg by (server) (rate(node_cpu_seconds_total{mode="idle"}[5m]))) * 100
```

Тогда дневные агрегаты будут легче:

```promql
avg_over_time(instance:cpu_utilization:percent[1d:5m])
max_over_time(instance:cpu_utilization:percent[1d:5m])
min_over_time(instance:cpu_utilization:percent[1d:5m])
```

---

## 4. Важные нюансы

| Нюанс | Пояснение |
|---|---|
| **Лейбл `server`** | node_exporter по умолчанию использует `instance`. Если у вас `server` — значит он добавлен через relabeling. Подставьте свой лейбл. |
| **`[1d:5m]`** | `1d` — окно агрегации, `5m` — шаг (resolution). Чем меньше шаг, тем точнее, но дороже. |
| **Load > 100%** | Load average может быть > 100% — это значит очередь задач больше числа ядер. CPU utilization ограничен 100%. |
| **`iowait`** | `rate(node_cpu_seconds_total{mode="idle"})` не включает `iowait` в idle. Если хотите считать I/O wait как «не нагрузку», добавьте `mode=~"idle\|iowait"`. |

---

## 5. Справка: разница между CPU Utilization и Load Average

- **CPU Utilization** — доля времени, когда CPU не idle. Capped at 100%. Считается ядром ОС через `/proc/stat`.
- **Load Average** — экспоненциально сглаженное среднее количества процессов в состоянии runnable + uninterruptible sleep (D-state). Может превышать 100% при делении на количество ядер — это значит, что задач больше, чем процессор может обработать одновременно.
- Единого ISO/POSIX стандарта на расчёт этих метрик **не существует** — это де-факто соглашения внутри каждой ОС.
