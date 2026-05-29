// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_log.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetScanLogCollection on Isar {
  IsarCollection<ScanLog> get scanLogs => this.collection();
}

const ScanLogSchema = CollectionSchema(
  name: r'ScanLog',
  id: -4582218631738629911,
  properties: {
    r'co2': PropertySchema(
      id: 0,
      name: r'co2',
      type: IsarType.double,
    ),
    r'decibel': PropertySchema(
      id: 1,
      name: r'decibel',
      type: IsarType.double,
    ),
    r'humidity': PropertySchema(
      id: 2,
      name: r'humidity',
      type: IsarType.double,
    ),
    r'light': PropertySchema(
      id: 3,
      name: r'light',
      type: IsarType.double,
    ),
    r'pm25': PropertySchema(
      id: 4,
      name: r'pm25',
      type: IsarType.double,
    ),
    r'roomName': PropertySchema(
      id: 5,
      name: r'roomName',
      type: IsarType.string,
    ),
    r'score': PropertySchema(
      id: 6,
      name: r'score',
      type: IsarType.double,
    ),
    r'temperature': PropertySchema(
      id: 7,
      name: r'temperature',
      type: IsarType.double,
    ),
    r'timestamp': PropertySchema(
      id: 8,
      name: r'timestamp',
      type: IsarType.dateTime,
    ),
    r'voc': PropertySchema(
      id: 9,
      name: r'voc',
      type: IsarType.double,
    ),
    r'warnings': PropertySchema(
      id: 10,
      name: r'warnings',
      type: IsarType.stringList,
    )
  },
  estimateSize: _scanLogEstimateSize,
  serialize: _scanLogSerialize,
  deserialize: _scanLogDeserialize,
  deserializeProp: _scanLogDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _scanLogGetId,
  getLinks: _scanLogGetLinks,
  attach: _scanLogAttach,
  version: '3.1.0+1',
);

int _scanLogEstimateSize(
  ScanLog object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.roomName.length * 3;
  bytesCount += 3 + object.warnings.length * 3;
  {
    for (var i = 0; i < object.warnings.length; i++) {
      final value = object.warnings[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _scanLogSerialize(
  ScanLog object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDouble(offsets[0], object.co2);
  writer.writeDouble(offsets[1], object.decibel);
  writer.writeDouble(offsets[2], object.humidity);
  writer.writeDouble(offsets[3], object.light);
  writer.writeDouble(offsets[4], object.pm25);
  writer.writeString(offsets[5], object.roomName);
  writer.writeDouble(offsets[6], object.score);
  writer.writeDouble(offsets[7], object.temperature);
  writer.writeDateTime(offsets[8], object.timestamp);
  writer.writeDouble(offsets[9], object.voc);
  writer.writeStringList(offsets[10], object.warnings);
}

ScanLog _scanLogDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ScanLog();
  object.co2 = reader.readDouble(offsets[0]);
  object.decibel = reader.readDouble(offsets[1]);
  object.humidity = reader.readDouble(offsets[2]);
  object.id = id;
  object.light = reader.readDouble(offsets[3]);
  object.pm25 = reader.readDouble(offsets[4]);
  object.roomName = reader.readString(offsets[5]);
  object.score = reader.readDouble(offsets[6]);
  object.temperature = reader.readDouble(offsets[7]);
  object.timestamp = reader.readDateTime(offsets[8]);
  object.voc = reader.readDouble(offsets[9]);
  object.warnings = reader.readStringList(offsets[10]) ?? [];
  return object;
}

P _scanLogDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDouble(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readStringList(offset) ?? []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _scanLogGetId(ScanLog object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _scanLogGetLinks(ScanLog object) {
  return [];
}

void _scanLogAttach(IsarCollection<dynamic> col, Id id, ScanLog object) {
  object.id = id;
}

extension ScanLogQueryWhereSort on QueryBuilder<ScanLog, ScanLog, QWhere> {
  QueryBuilder<ScanLog, ScanLog, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ScanLogQueryWhere on QueryBuilder<ScanLog, ScanLog, QWhereClause> {
  QueryBuilder<ScanLog, ScanLog, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ScanLogQueryFilter
    on QueryBuilder<ScanLog, ScanLog, QFilterCondition> {
  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> co2EqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'co2',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> co2GreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'co2',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> co2LessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'co2',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> co2Between(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'co2',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> decibelEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'decibel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> decibelGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'decibel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> decibelLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'decibel',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> decibelBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'decibel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> humidityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'humidity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> humidityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'humidity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> humidityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'humidity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> humidityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'humidity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> lightEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'light',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> lightGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'light',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> lightLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'light',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> lightBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'light',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> pm25EqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'pm25',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> pm25GreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'pm25',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> pm25LessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'pm25',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> pm25Between(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'pm25',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> roomNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> roomNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'roomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> roomNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'roomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> roomNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'roomName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> roomNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'roomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> roomNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'roomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> roomNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'roomName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> roomNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'roomName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> roomNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'roomName',
        value: '',
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> roomNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'roomName',
        value: '',
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> scoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'score',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> scoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'score',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> scoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'score',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> scoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'score',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> temperatureEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'temperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> temperatureGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'temperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> temperatureLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'temperature',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> temperatureBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'temperature',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> timestampEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> timestampGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> timestampLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'timestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> timestampBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'timestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> vocEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'voc',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> vocGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'voc',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> vocLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'voc',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> vocBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'voc',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> warningsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'warnings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition>
      warningsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'warnings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> warningsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'warnings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> warningsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'warnings',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition>
      warningsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'warnings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> warningsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'warnings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> warningsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'warnings',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> warningsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'warnings',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition>
      warningsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'warnings',
        value: '',
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition>
      warningsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'warnings',
        value: '',
      ));
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> warningsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'warnings',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> warningsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'warnings',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> warningsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'warnings',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> warningsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'warnings',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition>
      warningsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'warnings',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterFilterCondition> warningsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'warnings',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension ScanLogQueryObject
    on QueryBuilder<ScanLog, ScanLog, QFilterCondition> {}

extension ScanLogQueryLinks
    on QueryBuilder<ScanLog, ScanLog, QFilterCondition> {}

extension ScanLogQuerySortBy on QueryBuilder<ScanLog, ScanLog, QSortBy> {
  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByCo2() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'co2', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByCo2Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'co2', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByDecibel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decibel', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByDecibelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decibel', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByHumidity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'humidity', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByHumidityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'humidity', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByLight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'light', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByLightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'light', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByPm25() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pm25', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByPm25Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pm25', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByRoomName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomName', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByRoomNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomName', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByTemperatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByVoc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voc', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> sortByVocDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voc', Sort.desc);
    });
  }
}

extension ScanLogQuerySortThenBy
    on QueryBuilder<ScanLog, ScanLog, QSortThenBy> {
  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByCo2() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'co2', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByCo2Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'co2', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByDecibel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decibel', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByDecibelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'decibel', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByHumidity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'humidity', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByHumidityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'humidity', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByLight() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'light', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByLightDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'light', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByPm25() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pm25', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByPm25Desc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'pm25', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByRoomName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomName', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByRoomNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'roomName', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'score', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByTemperatureDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'temperature', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'timestamp', Sort.desc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByVoc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voc', Sort.asc);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QAfterSortBy> thenByVocDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'voc', Sort.desc);
    });
  }
}

extension ScanLogQueryWhereDistinct
    on QueryBuilder<ScanLog, ScanLog, QDistinct> {
  QueryBuilder<ScanLog, ScanLog, QDistinct> distinctByCo2() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'co2');
    });
  }

  QueryBuilder<ScanLog, ScanLog, QDistinct> distinctByDecibel() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'decibel');
    });
  }

  QueryBuilder<ScanLog, ScanLog, QDistinct> distinctByHumidity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'humidity');
    });
  }

  QueryBuilder<ScanLog, ScanLog, QDistinct> distinctByLight() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'light');
    });
  }

  QueryBuilder<ScanLog, ScanLog, QDistinct> distinctByPm25() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'pm25');
    });
  }

  QueryBuilder<ScanLog, ScanLog, QDistinct> distinctByRoomName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'roomName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ScanLog, ScanLog, QDistinct> distinctByScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'score');
    });
  }

  QueryBuilder<ScanLog, ScanLog, QDistinct> distinctByTemperature() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'temperature');
    });
  }

  QueryBuilder<ScanLog, ScanLog, QDistinct> distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'timestamp');
    });
  }

  QueryBuilder<ScanLog, ScanLog, QDistinct> distinctByVoc() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'voc');
    });
  }

  QueryBuilder<ScanLog, ScanLog, QDistinct> distinctByWarnings() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'warnings');
    });
  }
}

extension ScanLogQueryProperty
    on QueryBuilder<ScanLog, ScanLog, QQueryProperty> {
  QueryBuilder<ScanLog, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ScanLog, double, QQueryOperations> co2Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'co2');
    });
  }

  QueryBuilder<ScanLog, double, QQueryOperations> decibelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'decibel');
    });
  }

  QueryBuilder<ScanLog, double, QQueryOperations> humidityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'humidity');
    });
  }

  QueryBuilder<ScanLog, double, QQueryOperations> lightProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'light');
    });
  }

  QueryBuilder<ScanLog, double, QQueryOperations> pm25Property() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'pm25');
    });
  }

  QueryBuilder<ScanLog, String, QQueryOperations> roomNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'roomName');
    });
  }

  QueryBuilder<ScanLog, double, QQueryOperations> scoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'score');
    });
  }

  QueryBuilder<ScanLog, double, QQueryOperations> temperatureProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'temperature');
    });
  }

  QueryBuilder<ScanLog, DateTime, QQueryOperations> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'timestamp');
    });
  }

  QueryBuilder<ScanLog, double, QQueryOperations> vocProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'voc');
    });
  }

  QueryBuilder<ScanLog, List<String>, QQueryOperations> warningsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'warnings');
    });
  }
}
